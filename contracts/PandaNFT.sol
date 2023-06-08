// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "erc721a/contracts/ERC721A.sol";
import "@openzeppelin/contracts/token/common/ERC2981.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "operator-filter-registry/src/DefaultOperatorFilterer.sol";

contract PandaNFT is ERC721A, ERC2981, Ownable, DefaultOperatorFilterer {
    using SafeMath for uint256;

    uint256 public constant MAX_SUPPLY = 100;
    uint256 public MINT_FEE = 0.001 ether;
    uint256 public MINT_FEE_INCREMENT = 0.0001 ether;

    mapping(address => bool) public whitelist;

    uint256 private _flag = 1;
    string private _defTokenURI =
        "ipfs://QmZjDXmuLnEbAvU3KWB2G49SDhnVArkF2hkCcMJPek9wh3";
    string private _baseTokenURI =
        "ipfs://QmeoQLPC9bYmTxUMoYvucEy5oreScmv3Zdo1AdSgqkV6qR/";

    address private constant COLLECTION_OWNER =
        0xcfC55DF43fB52CC8a6107AFb74798054Aa11f5c4;

    event NewMint(address indexed msgSender, uint256 indexed mintQuantity);

    constructor() ERC721A("PandaNFT", "Panda") {
        _setDefaultRoyalty(msg.sender, 0);
        transferOwnership(COLLECTION_OWNER);
    }

    function supportsInterface(
        bytes4 interfaceId
    ) public view virtual override(ERC721A, ERC2981) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    function _startTokenId() internal view virtual override returns (uint256) {
        return 1;
    }

    function setWhiteList(address _address, bool _value) public onlyOwner {
        whitelist[_address] = _value;
    }

    function increaseMintFee() public {
        require(
            owner() == msg.sender || whitelist[msg.sender],
            "You are not permitted to increase the mint fee"
        );
        MINT_FEE += MINT_FEE_INCREMENT;
    }

    function transferOut(address _to) public onlyOwner {
        uint256 balance = address(this).balance;
        (bool success, ) = payable(_to).call{value: balance}("");
        require(success, "transferOut failed");
    }

    function changeTokenURIFlag(uint256 flag) external onlyOwner {
        _flag = flag;
    }

    function changeDefURI(string calldata _tokenURI) external onlyOwner {
        _defTokenURI = _tokenURI;
    }

    function changeURI(string calldata _tokenURI) external onlyOwner {
        _baseTokenURI = _tokenURI;
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return _baseTokenURI;
    }

    function tokenURI(
        uint256 tokenId
    ) public view override returns (string memory) {
        if (_flag == 0) {
            return _defTokenURI;
        } else {
            require(
                _exists(tokenId),
                "ERC721Metadata: URI query for nonexistent token"
            );
            return
                string(
                    abi.encodePacked(_baseTokenURI, Strings.toString(tokenId))
                );
        }
    }

    function mint(uint256 quantity) public payable {
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
