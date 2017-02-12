### Show system info
command archey -c 

[ -n "$PS1" ]
# source ~/.bash_profile

### Added by the Heroku Toolbelt
export PATH="/usr/local/heroku/bin:$PATH"

### Wakatime for Bash 
source $HOME/master/bash-wakatime/bash-wakatime.sh

function yesterworkday() 
{ 
    if [[ "1" == "$(date +%u)" ]]
    then 
        echo "last friday"
    else
        echo "yesterday"
    fi
}

function ec2start()
{
    aws ec2 start-instances --instance-ids "$1"
}

function ec2stop()
{
    aws ec2 stop-instances --instance-ids "$1"
}



[ -f ~/.fzf.bash ] && source ~/.fzf.bash
