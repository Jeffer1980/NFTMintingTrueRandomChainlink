pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBase.sol";

contract EXAMPLE is ERC721URIStorage, VRFConsumerBase {
        uint256 public tokenCounter;
    enum RizeType{FIRST_R, SECOND_R, THIRD_R}
    // add other things
    mapping(bytes32 => address) public requestIdToSender;
    mapping(bytes32 => string) public requestIdToTokenURI;
    mapping(uint256 => RizeType) public tokenIdToRizerType;
    mapping(bytes32 => uint256) public requestIdToTokenId;
    event requestedCollectible(bytes32 indexed requestId);
	uint256 MAX_TOKENS=10000;


    bytes32 internal keyHash;
    uint256 internal fee;
    
    constructor(address _VRFCoordinator, address _LinkToken, bytes32 _keyhash)
    public 
    VRFConsumerBase(_VRFCoordinator, _LinkToken)
    ERC721("EXAMPLE", "EXA")
    {
        tokenCounter = 0;
        keyHash = _keyhash;
        fee = 0.1 * 10 ** 18;
    }

    function createRizer(string memory tokenURI) 
        public returns (bytes32) {
            require(MAX_TOKENS > tokenCounter + 1, "Not enough tokens left to buy.");
			bytes32 requestId = requestRandomness(keyHash, fee);
            requestIdToSender[requestId] = msg.sender;
            requestIdToTokenURI[requestId] = tokenURI;
            emit requestedCollectible(requestId);
        }

    function fulfillRandomness(bytes32 requestId, uint256 randomNumber) internal override {
        address rizerOwner = requestIdToSender[requestId];
        string memory tokenURI = requestIdToTokenURI[requestId];
        uint256 newItemId = tokenCounter;
        _safeMint(rizerOwner, newItemId);
        _setTokenURI(newItemId, tokenURI);
        RizeType rizeType = RizeType(randomNumber % 3); 
        tokenIdToRizerType[newItemId] = rizeType;
        requestIdToTokenId[requestId] = newItemId;
        tokenCounter = tokenCounter + 1;
    }

    function setTokenURI(uint256 tokenId, string memory _tokenURI) public {
        require(
            _isApprovedOrOwner(_msgSender(), tokenId),
            "ERC721: transfer caller is not owner nor approved"
        );
        _setTokenURI(tokenId, _tokenURI);
    }
}