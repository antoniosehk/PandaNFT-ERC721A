// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "erc721a/contracts/ERC721A.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

interface IVRFv2Consumer {
    function requestRandomWords() external returns (uint256 requestId);

    function getRequestStatus(
        uint256 _requestId
    ) external view returns (bool fulfilled, uint256[] memory randomWords);
}

contract PandaNFT is ERC721A, Ownable {
    uint256 public constant MAX_SUPPLY = 100;
    uint256 public MINT_FEE = 0.001 ether;
    uint256 public constant MINT_FEE_RANDOM = 0.01 ether;
    uint256 public constant MINT_FEE_INCREMENT = 0.0001 ether;
    address vRFV2ConsumerAddress;

    // the white list is for address that can increase mint fee
    mapping(address => bool) public whiteListAddress;

    mapping(address => uint256) public addressToRequestId;
    mapping(uint256 => bool) public claimed;

    string public baseTokenURI =
        "ipfs://QmeoQLPC9bYmTxUMoYvucEy5oreScmv3Zdo1AdSgqkV6qR/";

    event NewMint(address indexed msgSender, uint256 indexed mintQuantity);

    constructor(
        address _owner,
        address _vRFV2ConsumerAddress
    ) ERC721A("PandaNFT", "Panda") {
        transferOwnership(_owner);
        vRFV2ConsumerAddress = _vRFV2ConsumerAddress;
    }

    function setVRFV2ConsumerAddress(address _address) external onlyOwner {
        vRFV2ConsumerAddress = _address;
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
        require(
            _exists(tokenId),
            "ERC721Metadata: URI query for nonexistent token"
        );
        return
            string(abi.encodePacked(baseTokenURI, Strings.toString(tokenId)));
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

    function randomMint() external payable {
        require(
            totalSupply() + 10 <= MAX_SUPPLY,
            "ERC721: Exceeds maximum supply"
        );
        require(msg.value >= MINT_FEE_RANDOM, "ERC721: Insufficient payment");
        uint256 requestId = IVRFv2Consumer(vRFV2ConsumerAddress)
            .requestRandomWords();
        addressToRequestId[msg.sender] = requestId;
    }

    function checkIfRandomMintEligible(
        address _address
    ) public view returns (bool) {
        uint256 requestId = addressToRequestId[_address];
        if (requestId == 0) return false;
        (bool fulfilled, uint256[] memory randomWords) = IVRFv2Consumer(
            vRFV2ConsumerAddress
        ).getRequestStatus(requestId);
        if (!fulfilled) return false;
        if (randomWords[0] % 2 == 1) return false;
        if (claimed[requestId]) return false;

        return true;
    }

    function claim() external {
        require(
            totalSupply() + 10 <= MAX_SUPPLY,
            "ERC721: Exceeds maximum supply"
        );

        require(checkIfRandomMintEligible(msg.sender), "You are not eligible");

        uint256 requestId = addressToRequestId[msg.sender];
        claimed[requestId] = true;
        _safeMint(msg.sender, 10);
        emit NewMint(msg.sender, 10);
    }
}
