#!/bin/bash

#     This program is free software: you can redistribute it and/or modify
#     it under the terms of the GNU Affero General Public License as
#     published by the Free Software Foundation, either version 3 of the
#     License, or (at your option) any later version.
#
#     This program is distributed in the hope that it will be useful,
#     but WITHOUT ANY WARRANTY; without even the implied warranty of
#     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#     GNU Affero General Public License for more details.
#
#     You should have received a copy of the GNU Affero General Public License
#     along with this program.  If not, see <https://www.gnu.org/licenses/>.

# Install dependencies
sudo apt-get update
sudo apt-get install build-essential -y
sudo apt-get install python3 -y

sudo apt-get install curl -y
sudo apt-get install git -y
sudo apt-get install git-lfs -y


# Install NVM (Node Version Manager) required node.js
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.38.0/install.sh | bash
source $HOME/.nvm/nvm.sh
nvm install v18.15.0
npm install -g npm
npm update -g


# Clone Signal-Desktop repo
git clone https://github.com/signalapp/Signal-Desktop.git
cd Signal-Desktop
git-lfs install

# Build Signal

npm install --global yarn
yarn cache clean
yarn install --frozen-lockfile
yarn grunt
yarn build:webpack

# Edit package.json to add the option to produce .AppImage
python3 <<EOF
query = '''
      "target": [
        "deb"
      ],
'''

replacement = '''
      "target": [
        "deb",
        "AppImage"
      ],
'''

data = None
with open("package.json",'r') as file:
    data = file.read()
    data = data.replace(query,replacement)

with open("package.json",'w') as file:
    file.write(data)
EOF

# Build
yarn build-release
echo "Output is in Signal-Desktop/release/"

