// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "erc721a/contracts/ERC721A.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract PandaNFT is ERC721A, Ownable {
    uint256 public constant MAX_SUPPLY = 100;
    uint256 public MINT_FEE = 0.001 ether;
    uint256 public constant MINT_FEE_INCREMENT = 0.0001 ether;

    // the white list is for address that can increase mint fee
    mapping(address => bool) public whiteListAddress;

    bool public tokenModeFlag = true;

    string public defTokenURI =
        "ipfs://QmZjDXmuLnEbAvU3KWB2G49SDhnVArkF2hkCcMJPek9wh3";
    string public baseTokenURI =
        "ipfs://QmeoQLPC9bYmTxUMoYvucEy5oreScmv3Zdo1AdSgqkV6qR/";

    event NewMint(address indexed msgSender, uint256 indexed mintQuantity);

    constructor(address _owner) ERC721A("PandaNFT", "Panda") {
        transferOwnership(_owner);
    }

    function setTokenModeFlag(bool _flag) external onlyOwner {
        tokenModeFlag = _flag;
    }

    function setWhiteListAddress(
        address _address,
        bool _value
    ) external onlyOwner {
        whiteListAddress[_address] = _value;
    }

    function increaseMintFee() external {
        require(
            owner() == msg.sender || whiteListAddress[msg.sender],
            "You are not permitted to increase the mint fee"
        );
        MINT_FEE += MINT_FEE_INCREMENT;
    }

    function withdrawContractBalance(address _to) external onlyOwner {
        uint256 balance = address(this).balance;
        (bool success, ) = payable(_to).call{value: balance}("");
        require(success, "withdrawContractBalance failed");
    }

    function supportsInterface(
        bytes4 interfaceId
    ) public view virtual override(ERC721A) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    function updateDefTokenURI(string calldata _tokenURI) external onlyOwner {
        defTokenURI = _tokenURI;
    }

    function updateBaseTokenURI(string calldata _tokenURI) external onlyOwner {
        baseTokenURI = _tokenURI;
    }

    function _startTokenId() internal view virtual override returns (uint256) {
        return 1;
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return baseTokenURI;
    }

    function tokenURI(
        uint256 tokenId
    ) public view override returns (string memory) {
        if (!tokenModeFlag) {
            return defTokenURI;
        } else {
            require(
                _exists(tokenId),
                "ERC721Metadata: URI query for nonexistent token"
            );
            return
                string(
                    abi.encodePacked(baseTokenURI, Strings.toString(tokenId))
                );
        }
    }

    function mint(uint256 quantity) external payable {
        require(
            totalSupply() + quantity <= MAX_SUPPLY,
            "ERC721: Exceeds maximum supply"
        );
        require(
            quantity == 1 || quantity == 2 || quantity == 3,
            "ERC721: Invalid quantity"
        );

        require(
            msg.value >= MINT_FEE * quantity,
            "ERC721: Insufficient payment"
        );
        _safeMint(msg.sender, quantity);

        emit NewMint(msg.sender, quantity);
    }
}
