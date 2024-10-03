// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract DegenToken is ERC20, Ownable {
    mapping(address => string[]) private _purchases;
    mapping(address => mapping(string => uint256)) private _itemCounts; // Store item counts

    struct Item {
        string name;
        uint256 price;
    }

    Item[] private _inventory; // Array to store available items

    event ItemAdded(string name, uint256 price);

    // Pass msg.sender to the Ownable constructor
    constructor() ERC20("Degen", "DGN") Ownable(msg.sender) {
        // Initialize the inventory with some items
        _inventory.push(Item("shirt", 10));
        _inventory.push(Item("pants", 8));
        _inventory.push(Item("belt", 5));
    }

    function mint(address to, uint256 value) public onlyOwner {
        _mint(to, value);
    }

    function burn(uint256 value) public {
        _burn(msg.sender, value);
    }

    function redeem(string memory itemName) public {
        uint256 itemPrice = getItemPrice(itemName);
        require(itemPrice > 0, "Item not found in inventory");

        // Check the sender's balance and redeem the item
        require(balanceOf(msg.sender) >= itemPrice, "Insufficient balance");
        
        // Transfer tokens and record purchase
        _transfer(msg.sender, address(this), itemPrice);
        _purchases[msg.sender].push(itemName);
        _itemCounts[msg.sender][itemName] += 1; // Increase item count

        emit Transfer(msg.sender, address(this), itemPrice);
    }

    function getItemPrice(string memory itemName) internal view returns (uint256) {
        for (uint256 i = 0; i < _inventory.length; i++) {
            if (keccak256(abi.encodePacked(_inventory[i].name)) == keccak256(abi.encodePacked(itemName))) {
                return _inventory[i].price;
            }
        }
        return 0; // Item not found
    }

    function showInventory() public view returns (string memory) {
        string memory inventoryList = "";
        for (uint256 i = 0; i < _inventory.length; i++) {
            inventoryList = string(abi.encodePacked(inventoryList, _inventory[i].name, "(", uint2str(_inventory[i].price), ")"));
            if (i < _inventory.length - 1) {
                inventoryList = string(abi.encodePacked(inventoryList, ", "));
            }
        }
        return inventoryList;
    }

    function addItem(string memory itemName, uint256 itemPrice) public onlyOwner {
        _inventory.push(Item(itemName, itemPrice));
        emit ItemAdded(itemName, itemPrice);
    }

    function uint2str(uint256 _i) internal pure returns (string memory) {
        if (_i == 0) {
            return "0";
        }
        uint256 j = _i;
        uint256 length;
        while (j != 0) {
            length++;
            j /= 10;
        }
        bytes memory bstr = new bytes(length);
        uint256 k = length;
        while (_i != 0) {
            k = k - 1;
            bytes1 b1 = bytes1(uint8(48 + _i % 10));
            bstr[k] = b1;
            _i /= 10;
        }
        return string(bstr);
    }

    function getPurchases(address account) public view returns (string[] memory) {
        return _purchases[account];
    }

    function getItemCount(address account, string memory itemName) public view returns (uint256) {
        return _itemCounts[account][itemName];
    }
}
