# playground completion                                    -*- shell-script -*-

# This bash completions script was generated by
# completely (https://github.com/dannyben/completely)
# Modifying it manually is not recommended

_playground_completions_filter() {
  local words="$1"
  local cur=${COMP_WORDS[COMP_CWORD]}
  local result=()

  if [[ "${cur:0:1}" == "-" ]]; then
    echo "$words"
  
  else
    for word in $words; do
      [[ "${word:0:1}" != "-" ]] && result+=("$word")
    done

    echo "${result[*]}"

  fi
}

_playground_completions() {
  local cur=${COMP_WORDS[COMP_CWORD]}
  local compwords=("${COMP_WORDS[@]:1:$COMP_CWORD-1}")
  local compline="${compwords[*]}"

  case "$compline" in
    'topic set-schema-compatibility'*'--compatibility')
      while read -r; do COMPREPLY+=( "$REPLY" ); done < <( compgen -W "$(_playground_completions_filter "BACKWARD BACKWARD_TRANSITIVE FORWARD FORWARD_TRANSITIVE FULL FULL_TRANSITIVE NONE")" -- "$cur" )
      ;;

    'ccloud-connector create-or-update'*'--connector')
      while read -r; do COMPREPLY+=( "$REPLY" ); done < <( compgen -W "$(_playground_completions_filter "$(playground get-ccloud-connector-list)")" -- "$cur" )
      ;;

    'bootstrap-reproduction-model'*'--cluster-region')
      while read -r; do COMPREPLY+=( "$REPLY" ); done < <( compgen -W "$(_playground_completions_filter "$(playground get-kafka-region-list)")" -- "$cur" )
      ;;

    'bootstrap-reproduction-model'*'--connector-jar')
      while read -r; do COMPREPLY+=( "$REPLY" ); done < <( compgen -W "$(_playground_completions_filter "$(playground get-zip-or-jar-with-fzf --type jar "$cur")")" -- "$cur" )
      ;;

    'bootstrap-reproduction-model'*'--connector-zip')
      while read -r; do COMPREPLY+=( "$REPLY" ); done < <( compgen -W "$(_playground_completions_filter "$(playground get-zip-or-jar-with-fzf --type zip "$cur")")" -- "$cur" )
      ;;

    'debug enable-remote-debugging'*'--container')
      while read -r; do COMPREPLY+=( "$REPLY" ); done < <( compgen -W "$(_playground_completions_filter "$(docker ps --format '{{.Names}}')")" -- "$cur" )
      ;;

    'bootstrap-reproduction-model'*'--pipeline')
      while read -r; do COMPREPLY+=( "$REPLY" ); done < <( compgen -W "$(_playground_completions_filter "$(playground get-examples-list-with-fzf --without-repro --sink-only "$cur")")" -- "$cur" )
      ;;

    'bootstrap-reproduction-model'*'--producer')
      while read -r; do COMPREPLY+=( "$REPLY" ); done < <( compgen -W "$(_playground_completions_filter "none avro avro-with-key protobuf protobuf-with-key json-schema json-schema-with-key")" -- "$cur" )
      ;;

    'connector create-or-update'*'--connector')
      while read -r; do COMPREPLY+=( "$REPLY" ); done < <( compgen -W "$(_playground_completions_filter "$(playground get-connector-list)")" -- "$cur" )
      ;;

    'topic set-schema-compatibility'*'--topic')
      while read -r; do COMPREPLY+=( "$REPLY" ); done < <( compgen -W "$(_playground_completions_filter "$(playground get-topic-list)")" -- "$cur" )
      ;;

    'ccloud-connector show-lag'*'--connector')
      while read -r; do COMPREPLY+=( "$REPLY" ); done < <( compgen -W "$(_playground_completions_filter "$(playground get-ccloud-connector-list)")" -- "$cur" )
      ;;

    'ccloud-connector create-or-update'*'-c')
      while read -r; do COMPREPLY+=( "$REPLY" ); done < <( compgen -W "$(_playground_completions_filter "$(playground get-ccloud-connector-list)")" -- "$cur" )
      ;;

    'ccloud-connector delete'*'--connector')
      while read -r; do COMPREPLY+=( "$REPLY" ); done < <( compgen -W "$(_playground_completions_filter "$(playground get-ccloud-connector-list)")" -- "$cur" )
      ;;

    'bootstrap-reproduction-model'*'--file')
      while read -r; do COMPREPLY+=( "$REPLY" ); done < <( compgen -W "$(_playground_completions_filter "$(playground get-examples-list-with-fzf --without-repro "$cur")")" -- "$cur" )
      ;;

    'ccloud-connector resume'*'--connector')
      while read -r; do COMPREPLY+=( "$REPLY" ); done < <( compgen -W "$(_playground_completions_filter "$(playground get-ccloud-connector-list)")" -- "$cur" )
      ;;

    'ccloud-connector pause'*'--connector')
      while read -r; do COMPREPLY+=( "$REPLY" ); done < <( compgen -W "$(_playground_completions_filter "$(playground get-ccloud-connector-list)")" -- "$cur" )
      ;;

    'topic set-schema-compatibility'*'-t')
      while read -r; do COMPREPLY+=( "$REPLY" ); done < <( compgen -W "$(_playground_completions_filter "$(playground get-topic-list)")" -- "$cur" )
      ;;

    'ccloud-connector create-or-update'*)
      while read -r; do COMPREPLY+=( "$REPLY" ); done < <( compgen -W "$(_playground_completions_filter "--connector --help -c -h")" -- "$cur" )
      ;;

    'debug enable-remote-debugging'*'-c')
      while read -r; do COMPREPLY+=( "$REPLY" ); done < <( compgen -W "$(_playground_completions_filter "$(docker ps --format '{{.Names}}')")" -- "$cur" )
      ;;

    'topic get-number-records'*'--topic')
      while read -r; do COMPREPLY+=( "$REPLY" ); done < <( compgen -W "$(_playground_completions_filter "$(playground get-topic-list)")" -- "$cur" )
      ;;

    'bootstrap-reproduction-model'*'-p')
      while read -r; do COMPREPLY+=( "$REPLY" ); done < <( compgen -W "$(_playground_completions_filter "none avro avro-with-key protobuf protobuf-with-key json-schema json-schema-with-key")" -- "$cur" )
      ;;

    'connector log-level'*'--connector')
      while read -r; do COMPREPLY+=( "$REPLY" ); done < <( compgen -W "$(_playground_completions_filter "$(playground get-connector-list)")" -- "$cur" )
      ;;

    'debug block-traffic'*'--container')
      while read -r; do COMPREPLY+=( "$REPLY" ); done < <( compgen -W "$(_playground_completions_filter "$(docker ps --format '{{.Names}}')")" -- "$cur" )
      ;;

    'bootstrap-reproduction-model'*'-f')
      while read -r; do COMPREPLY+=( "$REPLY" ); done < <( compgen -W "$(_playground_completions_filter "$(playground get-examples-list-with-fzf --without-repro "$cur")")" -- "$cur" )
      ;;

    'connector show-lag'*'--connector')
      while read -r; do COMPREPLY+=( "$REPLY" ); done < <( compgen -W "$(_playground_completions_filter "$(playground get-connector-list)")" -- "$cur" )
      ;;

    'topic display-consumer-offsets'*)
      while read -r; do COMPREPLY+=( "$REPLY" ); done < <( compgen -W "$(_playground_completions_filter "--help -h")" -- "$cur" )
      ;;

    'topic set-schema-compatibility'*)
      while read -r; do COMPREPLY+=( "$REPLY" ); done < <( compgen -W "$(_playground_completions_filter "--compatibility --help --topic -h -t")" -- "$cur" )
      ;;

    'debug thread-dump'*'--container')
      while read -r; do COMPREPLY+=( "$REPLY" ); done < <( compgen -W "$(_playground_completions_filter "$(docker ps --format '{{.Names}}')")" -- "$cur" )
      ;;

    'container restart'*'--container')
      while read -r; do COMPREPLY+=( "$REPLY" ); done < <( compgen -W "$(_playground_completions_filter "$(docker ps --format '{{.Names}}')")" -- "$cur" )
      ;;

    'connector restart'*'--connector')
      while read -r; do COMPREPLY+=( "$REPLY" ); done < <( compgen -W "$(_playground_completions_filter "$(playground get-connector-list)")" -- "$cur" )
      ;;

    'debug enable-remote-debugging'*)
      while read -r; do COMPREPLY+=( "$REPLY" ); done < <( compgen -W "$(_playground_completions_filter "--container --help -c -h")" -- "$cur" )
      ;;

    'connector create-or-update'*'-c')
      while read -r; do COMPREPLY+=( "$REPLY" ); done < <( compgen -W "$(_playground_completions_filter "$(playground get-connector-list)")" -- "$cur" )
      ;;

    'connector resume'*'--connector')
      while read -r; do COMPREPLY+=( "$REPLY" ); done < <( compgen -W "$(_playground_completions_filter "$(playground get-connector-list)")" -- "$cur" )
      ;;

    'ccloud-connector show-lag'*'-c')
      while read -r; do COMPREPLY+=( "$REPLY" ); done < <( compgen -W "$(_playground_completions_filter "$(playground get-ccloud-connector-list)")" -- "$cur" )
      ;;

    'container resume'*'--container')
      while read -r; do COMPREPLY+=( "$REPLY" ); done < <( compgen -W "$(_playground_completions_filter "$(docker ps --format '{{.Names}}')")" -- "$cur" )
      ;;

    'bootstrap-reproduction-model'*)
      while read -r; do COMPREPLY+=( "$REPLY" ); done < <( compgen -W "$(_playground_completions_filter "--cluster-creds --cluster-environment --cluster-name --cluster-region --cluster-schema-registry-creds --connector-jar --connector-tag --connector-zip --custom-smt --description --enable-conduktor --enable-control-center --enable-jmx-grafana --enable-kcat --enable-ksqldb --enable-multiple-brokers --enable-multiple-connect-workers --enable-sql-datagen --enable-sr-maven-plugin-app --file --help --nb-producers --pipeline --producer --producer-schema-key --producer-schema-value --tag -d -f -h -n -p")" -- "$cur" )
      ;;

    'debug block-traffic'*'--action')
      while read -r; do COMPREPLY+=( "$REPLY" ); done < <( compgen -W "$(_playground_completions_filter "start stop")" -- "$cur" )
      ;;

    'connector delete'*'--connector')
      while read -r; do COMPREPLY+=( "$REPLY" ); done < <( compgen -W "$(_playground_completions_filter "$(playground get-connector-list)")" -- "$cur" )
      ;;

    'container pause'*'--container')
      while read -r; do COMPREPLY+=( "$REPLY" ); done < <( compgen -W "$(_playground_completions_filter "$(docker ps --format '{{.Names}}')")" -- "$cur" )
      ;;

    'connector log-level'*'--level')
      while read -r; do COMPREPLY+=( "$REPLY" ); done < <( compgen -W "$(_playground_completions_filter "INFO WARN DEBUG TRACE")" -- "$cur" )
      ;;

    'run-ccloud'*'--cluster-region')
      while read -r; do COMPREPLY+=( "$REPLY" ); done < <( compgen -W "$(_playground_completions_filter "$(playground get-kafka-region-list)")" -- "$cur" )
      ;;

    'connector pause'*'--connector')
      while read -r; do COMPREPLY+=( "$REPLY" ); done < <( compgen -W "$(_playground_completions_filter "$(playground get-connector-list)")" -- "$cur" )
      ;;

    'debug heap-dump'*'--container')
      while read -r; do COMPREPLY+=( "$REPLY" ); done < <( compgen -W "$(_playground_completions_filter "$(docker ps --format '{{.Names}}')")" -- "$cur" )
      ;;

    'debug log-level set'*'--level')
      while read -r; do COMPREPLY+=( "$REPLY" ); done < <( compgen -W "$(_playground_completions_filter "INFO WARN DEBUG TRACE")" -- "$cur" )
      ;;

    'get-jmx-metrics'*'--component')
      while read -r; do COMPREPLY+=( "$REPLY" ); done < <( compgen -W "$(_playground_completions_filter "zookeeper broker connect schema-registry")" -- "$cur" )
      ;;

    'topic get-number-records'*'-t')
      while read -r; do COMPREPLY+=( "$REPLY" ); done < <( compgen -W "$(_playground_completions_filter "$(playground get-topic-list)")" -- "$cur" )
      ;;

    'debug tcp-dump'*'--container')
      while read -r; do COMPREPLY+=( "$REPLY" ); done < <( compgen -W "$(_playground_completions_filter "$(docker ps --format '{{.Names}}')")" -- "$cur" )
      ;;

    'get-properties'*'--container')
      while read -r; do COMPREPLY+=( "$REPLY" ); done < <( compgen -W "$(_playground_completions_filter "$(docker ps --format '{{.Names}}')")" -- "$cur" )
      ;;

    'run-ccloud'*'--cluster-cloud')
      while read -r; do COMPREPLY+=( "$REPLY" ); done < <( compgen -W "$(_playground_completions_filter "aws gcp azure")" -- "$cur" )
      ;;

    'run-ccloud'*'--connector-jar')
      while read -r; do COMPREPLY+=( "$REPLY" ); done < <( compgen -W "$(_playground_completions_filter "$(playground get-zip-or-jar-with-fzf --type jar "$cur")")" -- "$cur" )
      ;;

    'connector create-or-update'*)
      while read -r; do COMPREPLY+=( "$REPLY" ); done < <( compgen -W "$(_playground_completions_filter "--connector --help -c -h")" -- "$cur" )
      ;;

    'run-ccloud'*'--connector-zip')
      while read -r; do COMPREPLY+=( "$REPLY" ); done < <( compgen -W "$(_playground_completions_filter "$(playground get-zip-or-jar-with-fzf --type zip "$cur")")" -- "$cur" )
      ;;

    'container get-ip-addresses'*)
      while read -r; do COMPREPLY+=( "$REPLY" ); done < <( compgen -W "$(_playground_completions_filter "--help -h")" -- "$cur" )
      ;;

    'container logs'*'--container')
      while read -r; do COMPREPLY+=( "$REPLY" ); done < <( compgen -W "$(_playground_completions_filter "$(docker ps --format '{{.Names}}')")" -- "$cur" )
      ;;

    'container exec'*'--container')
      while read -r; do COMPREPLY+=( "$REPLY" ); done < <( compgen -W "$(_playground_completions_filter "$(docker ps --format '{{.Names}}')")" -- "$cur" )
      ;;

    'container kill'*'--container')
      while read -r; do COMPREPLY+=( "$REPLY" ); done < <( compgen -W "$(_playground_completions_filter "$(docker ps --format '{{.Names}}')")" -- "$cur" )
      ;;

    'ccloud-connector delete'*'-c')
      while read -r; do COMPREPLY+=( "$REPLY" ); done < <( compgen -W "$(_playground_completions_filter "$(playground get-ccloud-connector-list)")" -- "$cur" )
      ;;

    'ccloud-connector resume'*'-c')
      while read -r; do COMPREPLY+=( "$REPLY" ); done < <( compgen -W "$(_playground_completions_filter "$(playground get-ccloud-connector-list)")" -- "$cur" )
      ;;

    'container ssh'*'--container')
      while read -r; do COMPREPLY+=( "$REPLY" ); done < <( compgen -W "$(_playground_completions_filter "$(docker ps --format '{{.Names}}')")" -- "$cur" )
      ;;

    'ccloud-connector pause'*'-c')
      while read -r; do COMPREPLY+=( "$REPLY" ); done < <( compgen -W "$(_playground_completions_filter "$(playground get-ccloud-connector-list)")" -- "$cur" )
      ;;

    'ccloud-connector show-lag'*)
      while read -r; do COMPREPLY+=( "$REPLY" ); done < <( compgen -W "$(_playground_completions_filter "--connector --help -c -h")" -- "$cur" )
      ;;

    'ccloud-connector plugins'*)
      while read -r; do COMPREPLY+=( "$REPLY" ); done < <( compgen -W "$(_playground_completions_filter "--help -h")" -- "$cur" )
      ;;

    'topic get-number-records'*)
      while read -r; do COMPREPLY+=( "$REPLY" ); done < <( compgen -W "$(_playground_completions_filter "--help --topic -h -t")" -- "$cur" )
      ;;

    'ccloud-connector status'*)
      while read -r; do COMPREPLY+=( "$REPLY" ); done < <( compgen -W "$(_playground_completions_filter "--help -h")" -- "$cur" )
      ;;

    'ccloud-connector resume'*)
      while read -r; do COMPREPLY+=( "$REPLY" ); done < <( compgen -W "$(_playground_completions_filter "--connector --help -c -h")" -- "$cur" )
      ;;

    'ccloud-connector delete'*)
      while read -r; do COMPREPLY+=( "$REPLY" ); done < <( compgen -W "$(_playground_completions_filter "--connector --help -c -h")" -- "$cur" )
      ;;

    're-run'*'--connector-jar')
      while read -r; do COMPREPLY+=( "$REPLY" ); done < <( compgen -W "$(_playground_completions_filter "$(playground get-zip-or-jar-with-fzf --type jar "$cur")")" -- "$cur" )
      ;;

    're-run'*'--connector-zip')
      while read -r; do COMPREPLY+=( "$REPLY" ); done < <( compgen -W "$(_playground_completions_filter "$(playground get-zip-or-jar-with-fzf --type zip "$cur")")" -- "$cur" )
      ;;

    'container exec'*'--shell')
      while read -r; do COMPREPLY+=( "$REPLY" ); done < <( compgen -W "$(_playground_completions_filter "bash sh ksh zsh")" -- "$cur" )
      ;;

    'topic describe'*'--topic')
      while read -r; do COMPREPLY+=( "$REPLY" ); done < <( compgen -W "$(_playground_completions_filter "$(playground get-topic-list)")" -- "$cur" )
      ;;

    'ccloud-connector pause'*)
      while read -r; do COMPREPLY+=( "$REPLY" ); done < <( compgen -W "$(_playground_completions_filter "--connector --help -c -h")" -- "$cur" )
      ;;

    'connector log-level'*'-c')
      while read -r; do COMPREPLY+=( "$REPLY" ); done < <( compgen -W "$(_playground_completions_filter "$(playground get-connector-list)")" -- "$cur" )
      ;;

    'debug log-level set'*'-l')
      while read -r; do COMPREPLY+=( "$REPLY" ); done < <( compgen -W "$(_playground_completions_filter "INFO WARN DEBUG TRACE")" -- "$cur" )
      ;;

    'connector log-level'*'-l')
      while read -r; do COMPREPLY+=( "$REPLY" ); done < <( compgen -W "$(_playground_completions_filter "INFO WARN DEBUG TRACE")" -- "$cur" )
      ;;

    'debug block-traffic'*'-c')
      while read -r; do COMPREPLY+=( "$REPLY" ); done < <( compgen -W "$(_playground_completions_filter "$(docker ps --format '{{.Names}}')")" -- "$cur" )
      ;;

    'connector show-lag'*'-c')
      while read -r; do COMPREPLY+=( "$REPLY" ); done < <( compgen -W "$(_playground_completions_filter "$(playground get-connector-list)")" -- "$cur" )
      ;;

    'topic produce'*'--input')
      while read -r; do COMPREPLY+=( "$REPLY" ); done < <( compgen -W "$(_playground_completions_filter "$(playground get-predefined-schemas "$cur")")" -- "$cur" )
      ;;

    'topic consume'*'--topic')
      while read -r; do COMPREPLY+=( "$REPLY" ); done < <( compgen -W "$(_playground_completions_filter "$(playground get-topic-list)")" -- "$cur" )
      ;;

    'topic produce'*'--topic')
      while read -r; do COMPREPLY+=( "$REPLY" ); done < <( compgen -W "$(_playground_completions_filter "$(playground get-topic-list)")" -- "$cur" )
      ;;

    'container ssh'*'--shell')
      while read -r; do COMPREPLY+=( "$REPLY" ); done < <( compgen -W "$(_playground_completions_filter "bash sh ksh zsh")" -- "$cur" )
      ;;

    'container restart'*'-c')
      while read -r; do COMPREPLY+=( "$REPLY" ); done < <( compgen -W "$(_playground_completions_filter "$(docker ps --format '{{.Names}}')")" -- "$cur" )
      ;;

    'debug thread-dump'*'-c')
      while read -r; do COMPREPLY+=( "$REPLY" ); done < <( compgen -W "$(_playground_completions_filter "$(docker ps --format '{{.Names}}')")" -- "$cur" )
      ;;

    'topic delete'*'--topic')
      while read -r; do COMPREPLY+=( "$REPLY" ); done < <( compgen -W "$(_playground_completions_filter "$(playground get-topic-list)")" -- "$cur" )
      ;;

    'connector restart'*'-c')
      while read -r; do COMPREPLY+=( "$REPLY" ); done < <( compgen -W "$(_playground_completions_filter "$(playground get-connector-list)")" -- "$cur" )
      ;;

    'run'*'--connector-zip')
      while read -r; do COMPREPLY+=( "$REPLY" ); done < <( compgen -W "$(_playground_completions_filter "$(playground get-zip-or-jar-with-fzf --type zip "$cur")")" -- "$cur" )
      ;;

    'debug log-level get'*)
      while read -r; do COMPREPLY+=( "$REPLY" ); done < <( compgen -W "$(_playground_completions_filter "--help --package -h -p")" -- "$cur" )
      ;;

    'connector delete'*'-c')
      while read -r; do COMPREPLY+=( "$REPLY" ); done < <( compgen -W "$(_playground_completions_filter "$(playground get-connector-list)")" -- "$cur" )
      ;;

    'run'*'--connector-jar')
      while read -r; do COMPREPLY+=( "$REPLY" ); done < <( compgen -W "$(_playground_completions_filter "$(playground get-zip-or-jar-with-fzf --type jar "$cur")")" -- "$cur" )
      ;;

    'debug block-traffic'*)
      while read -r; do COMPREPLY+=( "$REPLY" ); done < <( compgen -W "$(_playground_completions_filter "--action --container --destination --help --port -c -h")" -- "$cur" )
      ;;

    'connector log-level'*)
      while read -r; do COMPREPLY+=( "$REPLY" ); done < <( compgen -W "$(_playground_completions_filter "--connector --help --level -c -h -l")" -- "$cur" )
      ;;

    'container resume'*'-c')
      while read -r; do COMPREPLY+=( "$REPLY" ); done < <( compgen -W "$(_playground_completions_filter "$(docker ps --format '{{.Names}}')")" -- "$cur" )
      ;;

    'connector resume'*'-c')
      while read -r; do COMPREPLY+=( "$REPLY" ); done < <( compgen -W "$(_playground_completions_filter "$(playground get-connector-list)")" -- "$cur" )
      ;;

    'debug log-level set'*)
      while read -r; do COMPREPLY+=( "$REPLY" ); done < <( compgen -W "$(_playground_completions_filter "--help --level --package -h -l -p")" -- "$cur" )
      ;;

    'debug heap-dump'*'-c')
      while read -r; do COMPREPLY+=( "$REPLY" ); done < <( compgen -W "$(_playground_completions_filter "$(docker ps --format '{{.Names}}')")" -- "$cur" )
      ;;

    'connector show-lag'*)
      while read -r; do COMPREPLY+=( "$REPLY" ); done < <( compgen -W "$(_playground_completions_filter "--connector --help -c -h")" -- "$cur" )
      ;;

    'container pause'*'-c')
      while read -r; do COMPREPLY+=( "$REPLY" ); done < <( compgen -W "$(_playground_completions_filter "$(docker ps --format '{{.Names}}')")" -- "$cur" )
      ;;

    'connector versions'*)
      while read -r; do COMPREPLY+=( "$REPLY" ); done < <( compgen -W "$(_playground_completions_filter "--help -h")" -- "$cur" )
      ;;

    'container kill-all'*)
      while read -r; do COMPREPLY+=( "$REPLY" ); done < <( compgen -W "$(_playground_completions_filter "--help -h")" -- "$cur" )
      ;;

    'container recreate'*)
      while read -r; do COMPREPLY+=( "$REPLY" ); done < <( compgen -W "$(_playground_completions_filter "--help -h")" -- "$cur" )
      ;;

    'connector pause'*'-c')
      while read -r; do COMPREPLY+=( "$REPLY" ); done < <( compgen -W "$(_playground_completions_filter "$(playground get-connector-list)")" -- "$cur" )
      ;;

    'get-docker-compose'*)
      while read -r; do COMPREPLY+=( "$REPLY" ); done < <( compgen -W "$(_playground_completions_filter "--help -h")" -- "$cur" )
      ;;

    'get-jmx-metrics'*'-c')
      while read -r; do COMPREPLY+=( "$REPLY" ); done < <( compgen -W "$(_playground_completions_filter "zookeeper broker connect schema-registry")" -- "$cur" )
      ;;

    'container logs'*'-c')
      while read -r; do COMPREPLY+=( "$REPLY" ); done < <( compgen -W "$(_playground_completions_filter "$(docker ps --format '{{.Names}}')")" -- "$cur" )
      ;;

    'connector plugins'*)
      while read -r; do COMPREPLY+=( "$REPLY" ); done < <( compgen -W "$(_playground_completions_filter "--help -h")" -- "$cur" )
      ;;

    'debug tcp-dump'*'-c')
      while read -r; do COMPREPLY+=( "$REPLY" ); done < <( compgen -W "$(_playground_completions_filter "$(docker ps --format '{{.Names}}')")" -- "$cur" )
      ;;

    'get-properties'*'-c')
      while read -r; do COMPREPLY+=( "$REPLY" ); done < <( compgen -W "$(_playground_completions_filter "$(docker ps --format '{{.Names}}')")" -- "$cur" )
      ;;

    'debug thread-dump'*)
      while read -r; do COMPREPLY+=( "$REPLY" ); done < <( compgen -W "$(_playground_completions_filter "--container --help -c -h")" -- "$cur" )
      ;;

    'topic describe'*'-t')
      while read -r; do COMPREPLY+=( "$REPLY" ); done < <( compgen -W "$(_playground_completions_filter "$(playground get-topic-list)")" -- "$cur" )
      ;;

    'run-ccloud'*'--file')
      while read -r; do COMPREPLY+=( "$REPLY" ); done < <( compgen -W "$(_playground_completions_filter "$(playground get-examples-list-with-fzf --ccloud-only "$cur")")" -- "$cur" )
      ;;

    'container kill'*'-c')
      while read -r; do COMPREPLY+=( "$REPLY" ); done < <( compgen -W "$(_playground_completions_filter "$(docker ps --format '{{.Names}}')")" -- "$cur" )
      ;;

    'container exec'*'-c')
      while read -r; do COMPREPLY+=( "$REPLY" ); done < <( compgen -W "$(_playground_completions_filter "$(docker ps --format '{{.Names}}')")" -- "$cur" )
      ;;

    'connector restart'*)
      while read -r; do COMPREPLY+=( "$REPLY" ); done < <( compgen -W "$(_playground_completions_filter "--connector --help -c -h")" -- "$cur" )
      ;;

    'container restart'*)
      while read -r; do COMPREPLY+=( "$REPLY" ); done < <( compgen -W "$(_playground_completions_filter "--container --help -c -h")" -- "$cur" )
      ;;

    'topic produce'*'-t')
      while read -r; do COMPREPLY+=( "$REPLY" ); done < <( compgen -W "$(_playground_completions_filter "$(playground get-topic-list)")" -- "$cur" )
      ;;

    'container ssh'*'-s')
      while read -r; do COMPREPLY+=( "$REPLY" ); done < <( compgen -W "$(_playground_completions_filter "bash sh ksh zsh")" -- "$cur" )
      ;;

    'container ssh'*'-c')
      while read -r; do COMPREPLY+=( "$REPLY" ); done < <( compgen -W "$(_playground_completions_filter "$(docker ps --format '{{.Names}}')")" -- "$cur" )
      ;;

    'topic consume'*'-t')
      while read -r; do COMPREPLY+=( "$REPLY" ); done < <( compgen -W "$(_playground_completions_filter "$(playground get-topic-list)")" -- "$cur" )
      ;;

    'ccloud-connector'*)
      while read -r; do COMPREPLY+=( "$REPLY" ); done < <( compgen -W "$(_playground_completions_filter "--help -h create-or-update delete pause plugins resume show-lag status")" -- "$cur" )
      ;;

    'connector status'*)
      while read -r; do COMPREPLY+=( "$REPLY" ); done < <( compgen -W "$(_playground_completions_filter "--help -h")" -- "$cur" )
      ;;

    'connector resume'*)
      while read -r; do COMPREPLY+=( "$REPLY" ); done < <( compgen -W "$(_playground_completions_filter "--connector --help -c -h")" -- "$cur" )
      ;;

    'connector delete'*)
      while read -r; do COMPREPLY+=( "$REPLY" ); done < <( compgen -W "$(_playground_completions_filter "--connector --help -c -h")" -- "$cur" )
      ;;

    'container resume'*)
      while read -r; do COMPREPLY+=( "$REPLY" ); done < <( compgen -W "$(_playground_completions_filter "--container --help -c -h")" -- "$cur" )
      ;;

    'topic delete'*'-t')
      while read -r; do COMPREPLY+=( "$REPLY" ); done < <( compgen -W "$(_playground_completions_filter "$(playground get-topic-list)")" -- "$cur" )
      ;;

    'get-all-schemas'*)
      while read -r; do COMPREPLY+=( "$REPLY" ); done < <( compgen -W "$(_playground_completions_filter "--help --open -h -o")" -- "$cur" )
      ;;

    'container pause'*)
      while read -r; do COMPREPLY+=( "$REPLY" ); done < <( compgen -W "$(_playground_completions_filter "--container --help -c -h")" -- "$cur" )
      ;;

    'connector pause'*)
      while read -r; do COMPREPLY+=( "$REPLY" ); done < <( compgen -W "$(_playground_completions_filter "--connector --help -c -h")" -- "$cur" )
      ;;

    'debug log-level'*)
      while read -r; do COMPREPLY+=( "$REPLY" ); done < <( compgen -W "$(_playground_completions_filter "--help -h get set")" -- "$cur" )
      ;;

    'get-jmx-metrics'*)
      while read -r; do COMPREPLY+=( "$REPLY" ); done < <( compgen -W "$(_playground_completions_filter "--component --domain --help --open -c -d -h -o")" -- "$cur" )
      ;;

    'debug heap-dump'*)
      while read -r; do COMPREPLY+=( "$REPLY" ); done < <( compgen -W "$(_playground_completions_filter "--container --help -c -h")" -- "$cur" )
      ;;

    'container kill'*)
      while read -r; do COMPREPLY+=( "$REPLY" ); done < <( compgen -W "$(_playground_completions_filter "--container --help -c -h")" -- "$cur" )
      ;;

    'get-properties'*)
      while read -r; do COMPREPLY+=( "$REPLY" ); done < <( compgen -W "$(_playground_completions_filter "--container --help -c -h")" -- "$cur" )
      ;;

    'debug tcp-dump'*)
      while read -r; do COMPREPLY+=( "$REPLY" ); done < <( compgen -W "$(_playground_completions_filter "--container --duration --help --port -c -h")" -- "$cur" )
      ;;

    'container exec'*)
      while read -r; do COMPREPLY+=( "$REPLY" ); done < <( compgen -W "$(_playground_completions_filter "--command --container --help --root --shell -c -h")" -- "$cur" )
      ;;

    'container logs'*)
      while read -r; do COMPREPLY+=( "$REPLY" ); done < <( compgen -W "$(_playground_completions_filter "--container --help --max-wait --open --wait-for-log -c -h -m -o -w")" -- "$cur" )
      ;;

    'topic describe'*)
      while read -r; do COMPREPLY+=( "$REPLY" ); done < <( compgen -W "$(_playground_completions_filter "--help --topic -h -t")" -- "$cur" )
      ;;

    'topic produce'*)
      while read -r; do COMPREPLY+=( "$REPLY" ); done < <( compgen -W "$(_playground_completions_filter "--forced-value --generate-only --help --input --key --nb-messages --nb-partitions --tombstone --topic -h -t")" -- "$cur" )
      ;;

    'topic consume'*)
      while read -r; do COMPREPLY+=( "$REPLY" ); done < <( compgen -W "$(_playground_completions_filter "--grep --help --max-messages --min-expected-messages --plot-latencies-timestamp-field --tail --timeout --topic -h -t")" -- "$cur" )
      ;;

    'container ssh'*)
      while read -r; do COMPREPLY+=( "$REPLY" ); done < <( compgen -W "$(_playground_completions_filter "--container --help --shell -c -h -s")" -- "$cur" )
      ;;

    'debug testssl'*)
      while read -r; do COMPREPLY+=( "$REPLY" ); done < <( compgen -W "$(_playground_completions_filter "--help -h")" -- "$cur" )
      ;;

    'run-ccloud'*'-f')
      while read -r; do COMPREPLY+=( "$REPLY" ); done < <( compgen -W "$(_playground_completions_filter "$(playground get-examples-list-with-fzf --ccloud-only "$cur")")" -- "$cur" )
      ;;

    'topic delete'*)
      while read -r; do COMPREPLY+=( "$REPLY" ); done < <( compgen -W "$(_playground_completions_filter "--help --topic -h -t")" -- "$cur" )
      ;;

    'topic create'*)
      while read -r; do COMPREPLY+=( "$REPLY" ); done < <( compgen -W "$(_playground_completions_filter "--help --nb-partitions --topic -h -t")" -- "$cur" )
      ;;

    'open'*'--file')
      while read -r; do COMPREPLY+=( "$REPLY" ); done < <( compgen -W "$(_playground_completions_filter "$(playground get-any-file-with-fzf "$cur")")" -- "$cur" )
      ;;

    'run-ccloud'*)
      while read -r; do COMPREPLY+=( "$REPLY" ); done < <( compgen -W "$(_playground_completions_filter "--cluster-cloud --cluster-creds --cluster-environment --cluster-name --cluster-region --cluster-schema-registry-creds --connector-jar --connector-tag --connector-zip --enable-conduktor --enable-control-center --enable-kcat --file --help --open --tag -f -h -o")" -- "$cur" )
      ;;

    'run'*'--file')
      while read -r; do COMPREPLY+=( "$REPLY" ); done < <( compgen -W "$(_playground_completions_filter "$(playground get-examples-list-with-fzf "$cur")")" -- "$cur" )
      ;;

    'connector'*)
      while read -r; do COMPREPLY+=( "$REPLY" ); done < <( compgen -W "$(_playground_completions_filter "--help -h create-or-update delete log-level pause plugins restart resume show-lag status versions")" -- "$cur" )
      ;;

    'container'*)
      while read -r; do COMPREPLY+=( "$REPLY" ); done < <( compgen -W "$(_playground_completions_filter "--help -h exec get-ip-addresses kill kill-all logs pause recreate restart resume ssh")" -- "$cur" )
      ;;

    'open'*'-f')
      while read -r; do COMPREPLY+=( "$REPLY" ); done < <( compgen -W "$(_playground_completions_filter "$(playground get-any-file-with-fzf "$cur")")" -- "$cur" )
      ;;

    're-run'*)
      while read -r; do COMPREPLY+=( "$REPLY" ); done < <( compgen -W "$(_playground_completions_filter "--clear --connector-jar --connector-tag --connector-zip --enable-conduktor --enable-control-center --enable-jmx-grafana --enable-kcat --enable-ksqldb --enable-multiple-brokers --enable-multiple-connect-workers --enable-sql-datagen --enable-sr-maven-plugin-app --help --tag -h")" -- "$cur" )
      ;;

    'run'*'-f')
      while read -r; do COMPREPLY+=( "$REPLY" ); done < <( compgen -W "$(_playground_completions_filter "$(playground get-examples-list-with-fzf "$cur")")" -- "$cur" )
      ;;

    'topic'*)
      while read -r; do COMPREPLY+=( "$REPLY" ); done < <( compgen -W "$(_playground_completions_filter "--help -h consume create delete describe display-consumer-offsets get-number-records produce set-schema-compatibility")" -- "$cur" )
      ;;

    'debug'*)
      while read -r; do COMPREPLY+=( "$REPLY" ); done < <( compgen -W "$(_playground_completions_filter "--help -h block-traffic enable-remote-debugging heap-dump log-level tcp-dump testssl thread-dump")" -- "$cur" )
      ;;

    'stop'*)
      while read -r; do COMPREPLY+=( "$REPLY" ); done < <( compgen -W "$(_playground_completions_filter "--help -h")" -- "$cur" )
      ;;

    'open'*)
      while read -r; do COMPREPLY+=( "$REPLY" ); done < <( compgen -W "$(_playground_completions_filter "--file --help -f -h")" -- "$cur" )
      ;;

    'run'*)
      while read -r; do COMPREPLY+=( "$REPLY" ); done < <( compgen -W "$(_playground_completions_filter "--connector-jar --connector-tag --connector-zip --enable-conduktor --enable-control-center --enable-jmx-grafana --enable-kcat --enable-ksqldb --enable-multiple-brokers --enable-multiple-connect-workers --enable-sql-datagen --enable-sr-maven-plugin-app --file --help --open --tag -f -h -o")" -- "$cur" )
      ;;

    *)
      while read -r; do COMPREPLY+=( "$REPLY" ); done < <( compgen -W "$(_playground_completions_filter "--help --version -h -v bootstrap-reproduction-model ccloud-connector connector container debug get-all-schemas get-docker-compose get-jmx-metrics get-properties open re-run run run-ccloud stop topic")" -- "$cur" )
      ;;

  esac
} &&
complete -F _playground_completions playground

# ex: filetype=sh
