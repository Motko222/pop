path=$(cd -- $(dirname -- "${BASH_SOURCE[0]}") && pwd) 
folder=$(echo $path | awk -F/ '{print $NF}')
cd #path

read -p "Sure? " c
case $c in y|Y) ;; *) exit ;; esac

#create env
cd $path
[ -f env ] || cp env.sample env
nano env

#install script
wget https://raw.githubusercontent.com/noderguru/pipe-testnet/refs/heads/main/install_pop_testnet-docker-full.sh
chmod +x install_pop_testnet-docker-full.sh
bash install_pop_testnet-docker-full.sh
