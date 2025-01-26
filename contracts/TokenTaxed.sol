// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract TokenTaxed is ERC20, Ownable {

    // Scaling factor for decimal precision.
    uint256 public constant SCALING_FACTOR = 10_000; 
    // Transfer tax rate in basis points. (default = 5%)
    uint256 public transferTaxRate;
    // Maximum tax rate in basis points. (default = 20%)
    uint256 public maxTaxRate;

    // Recipient addresses that are to be excluded from tax.
    mapping(address => bool) public noTaxRecipient;
    // Sender addresses that are to be excluded from tax.
    mapping(address => bool) public noTaxSender;

    //Token counters, no actual use.
    uint256 public totalMinted = 0;
    uint256 public totalBurned = 0;

    // Events
    event TransferTaxRateUpdated(address indexed owner, uint256 previousRate, uint256 newRate);
    event SetNoTaxSenderAddr(address indexed owner, address indexed noTaxSenderAddr, bool _value);
    event SetNoTaxRecipientAddr(address indexed owner, address indexed noTaxRecipientAddr, bool _value);

    // Constructor arguments for the TokenTaxed contract.
    constructor(
        string memory _name, // Full name of the token
        string memory _symbol, // Short name of the token
        uint256 _initialSupply, // Number of tokens to be minted. Expressed in ether. (ex. 100 = 100 tokens)
        uint256 _transferTaxRate, // Transfer tax rate to be imposed. Expressed in basis points (ex. 1_000 = 10%)
        uint256 _maxTaxRate // Maximum tax rate. Once set, CANNOT be modified again.

       ) ERC20(_name, _symbol) Ownable(msg.sender) {

        transferTaxRate = _transferTaxRate;
        maxTaxRate = _maxTaxRate;

        noTaxRecipient[msg.sender] = true;
        noTaxSender[msg.sender] = true;

        totalMinted = totalMinted + _initialSupply;
        _mint(msg.sender, _initialSupply);
    }

    // External privileged function to create or mint an X amount of tokens to a specified address.
    function mint(address _to, uint256 _amount) external onlyOwner {

        totalMinted = totalMinted + _amount;   
        _mint(_to, _amount);
    }

    // External function to burn or destroy an X amount of tokens.
    function burn(uint256 _amount) external {

        totalBurned = totalBurned + _amount;
        _burn(msg.sender, _amount);
    }

    // Overrides transfer function to meet tokenomics of tax token
    function _update(address from, address to, uint256 value) internal virtual override {
        
        // This computation results to a rounded up tax amount that can handle small amounts. Rounds up to minimum of 1 wei.
        uint256 taxAmount = (value * transferTaxRate + SCALING_FACTOR - 1 ) / SCALING_FACTOR;
        uint256 sendAmount = value - taxAmount;

        require(value == sendAmount + taxAmount, "Tax value invalid");

        if (taxAmount == 0 || noTaxRecipient[to] == true || noTaxSender[from] == true || from == address(0) || to == address(0)) {

            // Transfer with no Tax
            super._update(from, to, value);  
            
        } else {

            totalBurned = totalBurned + taxAmount;

            //Transfer with tax, burns the tax amount and transfers the net amount.
            _burn(from, taxAmount);
            super._update(from, to, sendAmount);
        }
    }

    // External privileged function to update the transfer tax rate up to the maximum tax rate set.
    function updateTransferTaxRate(uint256 _transferTaxRate) external onlyOwner {
        require(_transferTaxRate <= maxTaxRate, "Transfer tax rate must not exceed the maximum rate.");
        emit TransferTaxRateUpdated(msg.sender, transferTaxRate, _transferTaxRate);
        transferTaxRate = _transferTaxRate;
    }

    // External privileged function to update the no tax mapping for senders.
    function setNoTaxSenderAddr(address _noTaxSenderAddr, bool _value) external onlyOwner {
        noTaxSender[_noTaxSenderAddr] = _value;
        emit SetNoTaxSenderAddr(msg.sender, _noTaxSenderAddr, _value);
    }

    // External privileged function to update the no tax mapping for recipients.
    function setNoTaxRecipientAddr(address _noTaxRecipientAddr, bool _value) external onlyOwner {
        noTaxRecipient[_noTaxRecipientAddr] = _value;
        emit SetNoTaxRecipientAddr(msg.sender, _noTaxRecipientAddr, _value);
    }

    /* Contracts by: Kristian
     * Any issues and/or suggestions, you may reach me via:
     * Github: https://github.com/kristianism,
     * X (Twitter): https://x.com/defimagnate
    */

}
