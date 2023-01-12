# set bash timeout to 15 min
TMOUT=900
readonly TMOUT
export TMOUT


# prompt
# https://misc.flogisoft.com/bash/tip_colors_and_formatting
RED="\[$(tput setaf 1)\]"
GREEN="\[$(tput setaf 2)\]"
YELLOW="\[$(tput setaf 3)\]"
BLUE="\[$(tput setaf 4)\]"
CYAN="\[$(tput setaf 6)\]"
WHITE="\[$(tput setaf 7)\]"
RESET="\[$(tput sgr0)\]"
BOLD="\[$(tput bold)\]"

parse_kube_ctx() {
  grep "^current-context:" ~/.kube/config 2> /dev/null | \
  sed "s/^current-context: //" | \
  grep -v '""' | \
  sed -E -e "s/tink\.teleport\.sh-//" \
         -e "s/(minikube)/${CYAN//\\/\\\\}[\1]${RESET//\\/\\\\} /" \
         -e "s/(.+-testing)/${GREEN//\\/\\\\}[\1]${RESET//\\/\\\\} /" \
         -e "s/(.+-(staging|preprod))/${YELLOW//\\/\\\\}[\1]${RESET//\\/\\\\} /" \
         -e "s/(.+-production)/${RED//\\/\\\\}[\1]${RESET//\\/\\\\} /"
}

function build_prompt() {
    valid_for="$(tsh status 2>/dev/null | sed -n 's/.*\[\(.*\)\]/\1/p')"
    PS1="${BOLD}"
    PS1+="${RED}[${WHITE}\t${RED}] "                                        # timestamp
    PS1+="${BLUE}<${WHITE}teleport: ${valid_for:-n/a}${BLUE}> "  # teleport indicator
    PS1+="${BLUE}\W "                                                      # cwd
    PS1+="$(parse_kube_ctx)"                                                # k8s context
    PS1+="${BOLD}${YELLOW}$ ${RESET}"                                       # prompt indicator
}

PROMPT_COMMAND=build_prompt

PATH="${PATH}:${HOME}/google-cloud-sdk/bin"
export PATH

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/home/user/google-cloud-sdk/path.bash.inc' ]; then . '/home/user/google-cloud-sdk/path.bash.inc'; fi
# The next line enables shell command completion for gcloud.
if [ -f '/home/user/google-cloud-sdk/completion.bash.inc' ]; then . '/home/user/google-cloud-sdk/completion.bash.inc'; fi
# bash completion
source /etc/bash_completion
source <(kubectl completion bash)

alias tsh-init="tsh login --proxy=tink.teleport.sh:443"

function tsh-prod() {
    if [[ "${1}" =~ ^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}.*$ ]]; then
        tsh login --request-id="${1}"
    else
        CMD="tsh login --proxy=tink.teleport.sh:443 --request-roles=tink-production-user"
        if [ ! -z "${1}" ]; then
            CMD+=" --request-reason=\"${1}\""
        fi
        eval ${CMD}
    fi
}

function tsh-help() {
    echo
    echo -e "On first login use \e[1m\e[34mtsh-init\e[0m"
    echo
    echo -e "\e[1m\e[34mtsh-prod [REASON]\e[0m to request access to prod environments"
    echo -e "\e[1m\e[34mtsh-prod <request-id>\e[0m to login to prod after approval"
    echo
    echo -e "\e[1m\e[34mtsh kube ls\e[0m to list all clusters"
    echo -e "\e[1m\e[34mtsh kube login <clustername>\e[0m to log into a cluster"
    echo
}

tsh-help