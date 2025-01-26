## Taxed ERC20 Token
ERC20 Token with taxing capabilities for platform accumulation

### Solidity Version:
- 0.8.20

### Imports:
- @openzeppelin/contracts/access/Ownable.sol
- @openzeppelin/contracts/token/ERC20/ERC20.sol

### Constructor Arguments:
- _name: The full name of the token
- _symbol: The short name for the token or the ticker
- _initialSupply: The number of tokens to be pre-minted or pre-created to the deployer address
- _transferTaxRate: Transfer tax rate to be imposed. Expressed in basis points (ex. 1_000 = 10%)
- _maxTaxRate: Maximum tax rate. Once set, **CANNOT** be modified again.

### Functions:
- mint: Privileged function to create or mint an X amount of token/s to a specified address
- burn: External function to destroy an X amount of tokens from sender address
- updateTransferTaxRate: External privileged function to update the transfer tax rate up to the maximum tax rate set.
- setNoTaxSenderAddr: External privileged function to update the no tax mapping for senders.
- setNoTaxRecipientAddr: External privileged function to update the no tax mapping for recipients.
- Openzeppelin default Ownable functions
- Openzeppelin default ERC20 functions
