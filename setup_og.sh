#!/bin/bash
clear

if [[ ! -f "$HOME/.bash_profile" ]]; then
    touch "$HOME/.bash_profile"
fi

if [ -f "$HOME/.bash_profile" ]; then
    source $HOME/.bash_profile
fi

echo "===========EvmoS Protocol Install Easy======= " && sleep 1

read -p "Do you want run node OG Protocol ? (y/n): " choice

if [ "$choice" == "y" ]; then

sudo apt update && sudo apt upgrade -y
sudo apt install make curl git wget htop tmux build-essential jq make lz4 gcc unzip -y

#Install GO
ver="1.21.5"
wget "https://golang.org/dl/go$ver.linux-amd64.tar.gz"
sudo rm -rf /usr/local/go
sudo tar -C /usr/local -xzf "go$ver.linux-amd64.tar.gz"
rm "go$ver.linux-amd64.tar.gz"
echo "export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin" >> $HOME/.bash_profile
source $HOME/.bash_profile
go version


sudo apt install unzip -y
git clone -b v0.1.0 https://github.com/0glabs/0g-chain.git
./0g-chain/networks/testnet/install.sh
source .profile


0gchaind config keyring-backend test
0gchaind config chain-id zgtendermint_16600-1
0gchaind config node tcp://localhost:14257
0gchaind init NodeName --chain-id zgtendermint_16600-1


sed -i \
  -e 's|^chain-id *=.*|chain-id = "zgtendermint_16600-1"|' \
  -e 's|^keyring-backend *=.*|keyring-backend = "test"|' \
  -e 's|^node *=.*|node = "tcp://localhost:14257"|' \
  $HOME/.0gchain/config/client.toml


### downlaod genesis file
wget -P $HOME/.0gchain/config https://github.com/0glabs/0g-chain/releases/download/v0.1.0/genesis.json


SEEDS="c4d619f6088cb0b24b4ab43a0510bf9251ab5d7f@54.241.167.190:26656,44d11d4ba92a01b520923f51632d2450984d5886@54.176.175.48:26656,f2693dd86766b5bf8fd6ab87e2e970d564d20aff@54.193.250.204:26656,f878d40c538c8c23653a5b70f615f8dccec6fb9f@54.215.187.94:26656"
PEERS="f2693dd86766b5bf8fd6ab87e2e970d564d20aff@54.193.250.204:26656,9d7564df34efa146a94c073e5bf3f5e11f947b75@155.133.22.230:26656,e179d05dc792d9b902be3baa7a31a07a92afbcf0@118.142.83.5:26656,6382730e361db64311bcdb97d39907bee16950a9@43.159.62.244:26656,f64f0fb500c62bffa33d60450d30792ee4b5fbd0@167.86.119.168:26656,d4085fd93ab77576f2acdb25d2d817061db5afe6@62.169.19.156:26656,2b8ee12f4f94ebc337af94dbec07de6f029a24e6@94.16.31.161:26656,0f5022e4265184052a5468379687625a81fd255e@154.12.253.116:26656,3859828e1099214de14dae91d1f7decf2374eeb4@47.236.170.254:26656,23b0a0624699f85062ddebf910583f70a5b9e86b@14.167.152.116:14256,b8f8ed478f2794629fdb5cf0c01edaed80f00f84@168.119.64.172:26656,5d81d59e81356a33e6ccccaa3d419ff73244697e@107.173.18.103:26656,c4d619f6088cb0b24b4ab43a0510bf9251ab5d7f@54.241.167.190:26656,a83f5d07a8a64827851c9f1d0c21c900b9309608@188.166.181.110:26656,19943cbe46cdb9eb37cb06c0067ce63154eee6ea@213.199.52.155:26656,a6ff8a651dd0a0e66dbfb2174ccadcbbcf567b29@66.94.122.224:26656,07e9274106a0d3164dd961f74b48dc0e6bb850aa@123.101.99.79:26656,141dbd90d5c3411c9ba72ba03704ccdb70875b01@65.109.147.58:36656,cd529839591e13f5ed69e9a029c5d7d96de170fe@46.4.55.46:34656,a8d7c5a051c4649ba7e267c94e48a7c64a00f0eb@65.108.127.146:26656,2579a86e3c4c1fabe3955d3a9ed40363bf9618f7@138.201.37.195:26656,66cfdcd92e5206e59bc507bef3f6d72ed21a149d@109.199.100.254:26656,254bbbc42bca6b7e81081a42a4993086e20e06ed@89.116.29.154:26656,641173e9d500c50769680226391d955f11728c32@76.9.210.28:26656,5a69dafc859eee83b623b0c88b392337bb82eeb3@194.163.144.148:26656,3c2ddd1e25a99bcbad08f502eca719a52465c1fd@37.60.231.42:26656,f878d40c538c8c23653a5b70f615f8dccec6fb9f@54.215.187.94:26656,75a398f9e3a7d24c6b3ba4ab71bf30cd59faee5c@95.216.42.217:26656,57588ff7b1e862e754f3cd74fc2414f03cb79da4@213.133.111.189:26656,ebad6e8b1d10514185a8a46afb0f6a08945095bc@94.72.117.120:26656,ccb98fa0b1b416a9f37c08c193d4444074320c04@109.199.121.58:26656,b92597c5124da2a5177c1c2e11f69dfec45a721a@45.90.220.92:26656"
sed -i -e "s/^seeds *=.*/seeds = \"$SEEDS\"/; s/^persistent_peers *=.*/persistent_peers = \"$PEERS\"/" $HOME/.0gchain/config/config.toml




sed -i.bak -e "s%^proxy_app = \"tcp://127.0.0.1:26658\"%proxy_app = \"tcp://0.0.0.0:14258\"%; s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://0.0.0.0:14257\"%; s%^pprof_laddr = \"localhost:6060\"%pprof_laddr = \"localhost:14260\"%; s%^laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:14256\"%; s%^prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \":14266\"%" $HOME/.0gchain/config/config.toml
sed -i.bak -e "s%^address = \"tcp://localhost:1317\"%address = \"tcp://0.0.0.0:14217\"%; s%^address = \":8080\"%address = \":14280\"%; s%^address = \"0.0.0.0:9090\"%address = \"0.0.0.0:14290\"%; s%^address = \"0.0.0.0:9091\"%address = \"0.0.0.0:14291\"%; s%:8545%:14245%; s%:8546%:14246%; s%:6065%:14265%" $HOME/.0gchain/config/app.toml

# config pruning
sed -i -e "s/^pruning *=.*/pruning = \"custom\"/" $HOME/.0gchain/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"100\"/" $HOME/.0gchain/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"50\"/" $HOME/.0gchain/config/app.toml

# set minimum gas price, enable prometheus and disable indexing
sed -i 's|minimum-gas-prices =.*|minimum-gas-prices = "0.005ua0gi"|g' $HOME/.0gchain/config/app.toml
sed -i -e "s/prometheus = false/prometheus = true/" $HOME/.0gchain/config/config.toml
sed -i -e "s/^indexer *=.*/indexer = \"null\"/" $HOME/.0gchain/config/config.toml


sudo tee /etc/systemd/system/0gchaind.service > /dev/null <<EOF
[Unit]
Description=0gchaind Protocol
After=network-online.target
[Service]
User=root
ExecStart=$(which 0gchaind) start --home $HOME/.0gchain
Restart=always
RestartSec=3
LimitNOFILE=65535
[Install]
WantedBy=multi-user.target
EOF

cd $HOME

sudo systemctl daemon-reload
sudo systemctl enable 0gchaind
sudo systemctl restart 0gchaind && sudo journalctl -u 0gchaind -f --no-hostname -o cat


echo "===================Install Success==================="

else

echo "Not installed"

fi
