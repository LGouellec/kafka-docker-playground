instance="${args[--instance]}"
pem_file="${args[--pem-file]}"

if [[ $(type code 2>&1) =~ "not found" ]]
then
    logerror "❌ code command is not found - this command requires vscode to be installed"
    exit 1
fi

if [[ -n "$pem_file" ]]
then
    if [[ $pem_file == *"@"* ]]
    then
        pem_file=$(echo "$pem_file" | cut -d "@" -f 2)
    fi
elif [[ -n "$EC2_CLOUD_FORMATION_PEM_FILE" ]]
then
    pem_file="$EC2_CLOUD_FORMATION_PEM_FILE"
    if [ ! -f "$EC2_CLOUD_FORMATION_PEM_FILE" ]
    then
        logerror "❌ EC2_CLOUD_FORMATION_PEM_FILE is set with $EC2_CLOUD_FORMATION_PEM_FILE but the file does not exist"
        exit 1
    fi
else
    logerror "❌ --pem-file or EC2_CLOUD_FORMATION_PEM_FILE is required"
    exit 1
fi

if [[ $instance == *"@"* ]]
then
    instance=$(echo "$instance" | cut -d "@" -f 2)
fi
name=$(echo "${instance}" | cut -d "|" -f 1)
state=$(echo "${instance}" | cut -d "|" -f 2)
ip=$(echo "${instance}" | cut -d "|" -f 3)
id=$(echo "${instance}" | cut -d "|" -f 4)

group=$(aws ec2 describe-instances --instance-id $id --output=json | jq '.Reservations[] | .Instances[] | {SecurityGroups: .SecurityGroups}' | jq -r '.SecurityGroups[0] | .GroupName')

# delete all rules
aws ec2 revoke-security-group-ingress --group-name $group \
  --ip-permissions \
  "$(aws ec2 describe-security-groups --output json --group-name $group --query "SecurityGroups[0].IpPermissions")"

myip=$(dig @resolver4.opendns.com myip.opendns.com +short)
aws ec2 authorize-security-group-ingress --group-name "$group" --protocol tcp --port 22 --cidr $myip/32 > /dev/null 2>&1 &
if [ "$state" = "$EC2_INSTANCE_STATE_STOPPED" ]
then
    log "🚀 starting the ec2 instance $name with id $id"
    aws ec2 start-instances --instance-ids "$id"
    wait_for_ec2_instance_to_be_running "$name"
    ip=$(aws ec2 describe-instances --instance-ids "$id" | jq ".Reservations[0].Instances[0].PublicDnsName" | tr -d '"')
fi

mkdir -p $HOME/.ssh
SSH_CONFIG_FILE=$HOME/.ssh/config
username=$(whoami)

set +e
grep "$name" $SSH_CONFIG_FILE > /dev/null
if [ $? = 0 ]
then
    OLDIP=$(grep -w $name -A 1 ${SSH_CONFIG_FILE} | awk '/HostName/ {print $2}')
    sed -e "s/$OLDIP/$ip/g" ${SSH_CONFIG_FILE} > /tmp/tmp_file
    mv /tmp/tmp_file ${SSH_CONFIG_FILE}
else
cat << EOF >> ${SSH_CONFIG_FILE}

Host $name
  HostName $ip
  IdentityFile $pem_file
  User $username
  StrictHostKeyChecking no
EOF

fi
set -e

log "👨‍💻 Open EC2 instance $name using Visual Studio code (only your ip $myip is allowed to connect)"
code --folder-uri "vscode-remote://ssh-remote+$name/home/$username"