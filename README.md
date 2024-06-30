# ETH-AVAX-MODULE-4-DEGEN-TOKEN
## Project Description 
For this project, we will write an ERC20-compliant smart contract to create your own token on a local Hardhat network. To get started, we will use the Hardhat boilerplate project that is shown in the Hardhat Website itself, which provides a solid foundation. Once you have set up the Hardhat project, you can begin writing your smart contract. The contract should be compatible with Remix, allowing easy interaction. As the contract owner, you should have the ability to mint tokens to a specified address. Additionally, any user should be able to burn and transfer tokens to other addresses.

## Deployment Instructions 
1. open a command prompt and run this command: $ mkdir "YOUR PROJECT NAME" to create a named "YOUR PROJECT" in the location.
2. change the directory with this command: $ cd avalanche-project
3. run this command to create a new package.json: $$ npm init -y
4. install the hardhat development environment: $ npm install --save-dev hardhat
5. to run the hardhat, run this command: $ npx hardhat
  5.1 select the create a javascript project in order to generate a hardhat.config.js
6. to install the toolbox plugin of hardhat: $ npm i --save-dev @nomicfoundation/hardhat-toolbox
7. Install the OpenZeppelin Contracts library as a dependency by executing the following command: npm install @openzeppelin/contracts
8. Edit your hardhat.config.js
### hardhat.config.js
```javascript
require("@nomicfoundation/hardhat-toolbox");

const FORK_FUJI = false;
const FORK_MAINNET = false;
let forkingData = undefined;

if (FORK_MAINNET) {
  forkingData = {
    url: "https://api.avax.network/ext/bc/C/rpcc",
 

 };
}
if (FORK_FUJI) {
  forkingData = {
    url: "https://api.avax-test.network/ext/bc/C/rpc",
  };
}

module.exports = {
  solidity: "0.8.20",
  etherscan: {
    apiKey: "YOUR_API_KEY",
  },
  networks: {
    hardhat: {
      gasPrice: 225000000000,
      chainId: !forkingData ? 43112 : undefined,
      forking: forkingData,
    },
    fuji: {
      url: 'https://api.avax-test.network/ext/bc/C/rpc',
      gasPrice: 225000000000,
      chainId: 43113,
      accounts: [
        // YOUR PRIVATE KEY HERE
    
      ],
    },
    mainnet: {
      url: 'https://api.avax.network/ext/bc/C/rpc',
      gasPrice: 225000000000,
      chainId: 43114,
      accounts: [
        // YOUR PRIVATE KEY HERE
        
      ],
    },
  },
};
```
9. Also, edit the deploy.js, can be found in the scripts folder
### deploy.js
```javascript
const hre = require("hardhat");

async function main() {
	
  const DegenToken = await hre.ethers.deployContract("DegenToken",["Degen", "DGN"]);

  await DegenToken.waitForDeployment();

  console.log(`Contract Deployed to address ${await DegenToken.getAddress()}`);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
```

10. Go to the Avalanche Testnet Faucet website, and request 2 AVAX to your wallet account in order for the contract to run.
11. run the script with the fuji network with this command: $ npx hardhat run scripts/deploy.js --network fuji
12. Then go to the remix ethereum website, and copy the DegenToken.sol
13. In the deployment tab, there is an "At Address" tab there and copy the contract address there as well.
14. You can now do the functions!
### Degen.sol
```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract DegenToken is IERC20{
    string private _name;
    string private _symbol;
    address private _owner;
    mapping(address => uint256) private _balances;
    mapping(address => string[]) private _purchases; 
    uint256 private _totalSupply = 0;

    mapping(address => mapping(address => uint256)) private _allowances;

    event Burn(address from, uint256 value);
    event Mint(address to, uint256 value);

    constructor(string memory name, string memory symbol) {
        name = "Degen";
        symbol = "DGN";
        _owner = msg.sender;
    }

    function totalSupply() external view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) external view returns (uint256) {
        return _balances[account];
    }

    function transfer(address to, uint256 value) public returns (bool) {
        
        if (to == address(0)) {
            revert InvalidReceiver(address(0));
        }
        address sender = msg.sender;
        uint256 senderBalance = _balances[sender]; 
        if (_balances[sender] < value) {
            revert InsufficientBalance(sender, senderBalance, value);
        } 
        _balances[sender] -= value;
        _balances[to] += value;
        emit Transfer(sender, to, value);
        return true;
    }


    function burn(uint256 value) public returns(bool) {
        address sender = msg.sender;
        uint256 senderBalance = _balances[sender];
        if(_balances[sender] < value) {
            revert InsufficientBalance(sender, senderBalance, value);
        }
        _balances[sender] -= value;
        _totalSupply -= value;
        emit Burn(sender, value);
        return true;
    }

    function mint(address to, uint256 value) public returns(bool) {
        require(msg.sender == _owner, "Only owner is allowed to perform this operation"); 
        _balances[to] += value;
        _totalSupply += value;
        emit Mint(to, value);
        return true;
    }

    function getPurchases(address account) public view returns(string[] memory) {
        return _purchases[account];
    }

    function redeem(string memory itemName, uint256 value) public{
        address sender = msg.sender;
        uint256 senderBalance = _balances[sender];
        if(_balances[sender] < value) {
            revert InsufficientBalance(sender, senderBalance, value);
        }
        _balances[sender] -= value;
        _purchases[sender].push(itemName);
        emit Transfer(sender, address(this), value);
    }


    function allowance(address owner, address spender) external view returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 value) external returns (bool) {
        address owner = msg.sender;
        uint256 ownerBalance = _balances[owner];
        if (spender == address(0)) {
            revert InvalidReceiver(spender);
        }
        if (ownerBalance < value) {
            revert InsufficientBalance(owner, ownerBalance, value);
        }
        _balances[owner] -= value;
        _allowances[owner][spender] += value;
        emit Approval(owner, spender, value);
        return true;
    }

    function transferFrom(address from, address to, uint256 value) external returns (bool) {
        address spender = msg.sender;
        uint256 allowanceBalance =  _allowances[from][spender];

        if (to == address(0)) {
            revert InvalidReceiver(to);
        }
        if (allowanceBalance < value) {
            revert InsufficientAllowance(spender, from, allowanceBalance, value);
        }
        _allowances[from][spender] -= value;
        _balances[to] += value;
        emit Transfer(from, to, value);
        return true;
    }

    error InvalidReceiver(address _to);

    error InsufficientBalance(address from,uint256 fromBalance,uint256 value);

    error InsufficientAllowance(address spender, address from, uint256 currentAllowance, uint256 value);

}
```
