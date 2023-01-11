
# prompt
# https://misc.flogisoft.com/bash/tip_colors_and_formatting
RED="\[$(tput setaf 1)\]"
GREEN="\[$(tput setaf 2)\]"
BLUE="\[$(tput setaf 4)\]"
CYAN="\[$(tput setaf 6)\]"
WHITE="\[$(tput setaf 7)\]"
ORANGE="\[$(tput setaf 202)\]"
RESET="\[$(tput sgr0)\]"
BOLD="\[$(tput bold)\]"

parse_kube_ctx() {
  cat ~/.kube/config 2> /dev/null | \
  grep "^current-context:" | \
  sed "s/^current-context: //" | \
  grep -v '""' | \
  sed -E -e "s/tink\.teleport\.sh-//" \
         -e "s/(minikube)/${CYAN//\\/\\\\}[\1]${RESET//\\/\\\\} /" \
         -e "s/(.+-testing)/${GREEN//\\/\\\\}[\1]${RESET//\\/\\\\} /" \
         -e "s/(.+-(staging|preprod))/${ORANGE//\\/\\\\}[\1]${RESET//\\/\\\\} /" \
         -e "s/(.+-production)/${RED//\\/\\\\}[\1]${RESET//\\/\\\\} /"
}

function build_prompt() {
    valid_for="$(tsh status | sed -n 's/.*valid for \(.*\)]/\1/p')"
    PS1="${BOLD}"
    PS1+="${RED}[${WHITE}\t${RED}] "                                        # timestamp
    PS1+="${BLUE}<${WHITE}teleport: ${valid_for:-not logged in}${BLUE}> "  # teleport indicator
    PS1+="${BLUE}\W/ "                                                      # cwd
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
source <(kubectl completion bash)

alias teleport-init="tsh login --proxy=tink.teleport.sh:443 --bind-addr=127.0.0.1:36319"