// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../../SafeMath.sol";

import "../interfaces/IERC721.sol";
import "../interfaces/IERC721TokenReceiver.sol";
import "./ERC165.sol";

contract ERC721Impl is IERC721, IERC721TokenReceiver, ERC165 {
    using SafeMath for uint256;

    //may be moved from public to private
    mapping(uint256 => address) public tokenOwner;  //tokenId => tokenOwner ---> tokenOwner[tokenId]

    // Mapping owner address to token count
    mapping(address => uint256) public balances; //balances[tokenOwnerAddr]

    // Mapping from token ID to approved address
    mapping(uint256 => address) public approvedAddressForToken;
    //mapping(uint256 => address[]) public _tokenApprovals;

    // Mapping from owner to operator approvals
    //mapping(address => mapping(address => bool)) public _operatorApprovals;
    mapping(address => mapping(address => bool)) public multiAddrApproval;


    bytes4 constant InterfaceSignature_ERC721 =
        bytes4(keccak256('name()')) ^
        bytes4(keccak256('symbol()')) ^
        bytes4(keccak256('totalSupply()')) ^
        bytes4(keccak256('balanceOf(address)')) ^
        bytes4(keccak256('ownerOf(uint256)')) ^
        bytes4(keccak256('approve(address,uint256)')) ^
        bytes4(keccak256('transfer(address,uint256)')) ^
        bytes4(keccak256('transferFrom(address,address,uint256)')) ^
        bytes4(keccak256('tokensOfOwner(address)')) ^
        bytes4(keccak256('tokenMetadata(uint256,string)'));

    constructor() {
        _registerInterface(InterfaceSignature_ERC721);
    }


    ////////////////////////////////////////////////
    //            ERC721 IMPLEMENTATION           //
    ////////////////////////////////////////////////
        function balanceOf(address owner)
            public
            view
            virtual
            override
            returns(uint256)
        {
            require(owner != address(0x0),
                    "ERC721: MUST BE VALID ADDRESS"
            );

            return balances[owner];
        }


        function ownerOf(uint256 tokenId)
            public
            view
            virtual
            override
            returns(address) 
        {
            require(tokenOwner[tokenId] != address(0x0),
                    "ERC721: DEFAULT ADDRESS VALUE"
            );

            return tokenOwner[tokenId];
        }


    ////////////////////////////////////////////////
    //       ERC721 TRANSFER IMPLEMENTATION       //
    ////////////////////////////////////////////////
        function safeTransferFrom(address _fromAddr, address _toAddr, uint256 _tokenId)
            public
            payable
            virtual
            override
        {
            safeTransferFrom(_fromAddr, _toAddr, _tokenId, bytes(""));
        }


        function safeTransferFrom(address _fromAddr, address _toAddr, uint256 _tokenId, bytes memory _data)
            public
            payable
            virtual
            override
        {
            require(_isApprovedOrOwner(msg.sender, _tokenId),
                    "ERC721: TRANSFER CALLER IS NOT OWNER NOR APPROVED"
            );

            _safeTransfer(_fromAddr, _toAddr, _tokenId, _data);
        }

        
        function _safeTransfer(address _fromAddr, address _toAddr, uint256 _tokenId, bytes memory _data)
            internal
            virtual
        {
            _transfer(_fromAddr, _toAddr, _tokenId);
            require(_checkOnERC721Received(_fromAddr, _toAddr, _tokenId, _data), "ERC721: TRANSFER TO NON ERC721RECEIVER IMPLEMENTER");
        }
                
        
        function transferFrom(address _fromAddr, address _toAddr, uint256 _tokenId)
            external
            payable
            virtual
            override
        {
            require(_isApprovedOrOwner(msg.sender, _tokenId),
                    "ERC721: TRANSFER CALLER IS NOT OWNER NOR APPROVED"
            );

            _transfer(_fromAddr, _toAddr, _tokenId);
        }

        //_beforeTokenTransfer() will be added and given an implementation one day
        function _transfer(address _fromAddr, address _toAddr, uint256 _tokenId)
            internal
            virtual
        {
            require(ERC721Impl.ownerOf(_tokenId) == _fromAddr,
                    "ERC721: transfer of token that is not own"
            );

            require(_toAddr != address(0x0),
                    "ERC721: transfer to the zero address"
            );

        // _beforeTokenTransfer(_fromAddr, _toAddr, _tokenId);

            // Clear approvals from the previous owner
            _approve(address(0x0), _tokenId);

            balances[_fromAddr] = balances[_fromAddr].sub(1);
            balances[_toAddr] = balances[_toAddr].add(1);
            tokenOwner[_tokenId] = _toAddr;

            emit Transfer(_fromAddr, _toAddr, _tokenId);
        }


    ////////////////////////////////////////////////
    //      ERC721 APPROVAL IMPLEMENTATION        //
    ////////////////////////////////////////////////
        function approve(address _toAddr, uint256 _tokenId)
            public
            payable
            virtual
            override
        {
            //address owner = ERC721.ownerOf(_tokenId);
            address owner = ERC721Impl.ownerOf(_tokenId);

            require(_toAddr != owner,
                    "ERC721: CANNOT APPROVE CURRENT OWNER"
            );

            require(
                msg.sender == owner || isApprovedForAll(owner, msg.sender),
                "ERC721: MSG.SENDER IS NOT OWNER OR APPROVED FOR ALL"
            );

            _approve(_toAddr, _tokenId);
        }
        

        //used before all transfers
        function _approve(address _toAddr, uint256 _tokenId)
            internal
            virtual
        {
            approvedAddressForToken[_tokenId] = _toAddr;
            emit Approval(ERC721Impl.ownerOf(_tokenId), _toAddr, _tokenId);
        }


        function setApprovalForAll(address _operatorAddr, bool _approved)
            public
            virtual
            override
        {
            require(_operatorAddr != msg.sender,
                    "ERC721: approve to caller"
            );

            multiAddrApproval[msg.sender][_operatorAddr] = _approved;
            emit ApprovalForAll(msg.sender, _operatorAddr, _approved);
        }

        function isApprovedForAll(address _owner, address _operator)
            public
            view
            virtual
            override
            returns(bool)
        {
            return multiAddrApproval[_owner][_operator];
        }

        function getApproved(uint256 _tokenId)
            public
            view
            virtual
            override
            returns(address)
        {
            require(tokenExists(_tokenId),
                    "ERC721: CANNOT GET APPROVED STATUS FOR NONEXISTENT TOKEN"
            );

            return approvedAddressForToken[_tokenId];
        }


    ////////////////////////////////////////////////
    //             HELPER FUNCTIONS               //
    ////////////////////////////////////////////////
            
        //move to NoteBlock Helper
        function generateTokenId(
            address _senderAddr,
            uint256 _timestamp,
            string memory _ipfsURI
        )
            public
            view
            returns(uint256 newTokenId)
        {
            newTokenId = uint256(
                keccak256(
                    abi.encodePacked(_senderAddr, _timestamp, _ipfsURI)
                )
            );

            require(tokenExists(newTokenId) != true,
                    "ERC721: tokenId has already been generated, try again"
            );

        }


        
        function tokenExists(uint256 _tokenId)
            internal
            view
            virtual
            returns(bool)
        {
            return tokenOwner[_tokenId] != address(0x0);
        }

        function _isApprovedOrOwner(address spender, uint256 tokenId)
            internal
            view
            virtual
            returns(bool bIsApprovedOrOwner)
        {
            require(tokenExists(tokenId), 
                    "ERC721: CANNOT GET APPROVED STATUS FOR NONEXISTENT TOKEN"
            );
            
            address owner = ERC721Impl.ownerOf(tokenId);

            if(spender == owner || getApproved(tokenId) == spender || isApprovedForAll(owner, spender)) {
                bIsApprovedOrOwner = true;
            }
        }

        function isContract(address account)
            internal
            view
            returns(bool)
        {
            uint256 size;
            assembly {
                size := extcodesize(account)
            }
            return size > 0;
        }
        
        function toString(uint256 value) internal pure returns (string memory) {
            if (value == 0) {
                return "0";
            }
            uint256 temp = value;
            uint256 digits;
            while (temp != 0) {
                digits++;
                temp /= 10;
            }
            bytes memory buffer = new bytes(digits);
            while (value != 0) {
                digits -= 1;
                buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
                value /= 10;
            }
            return string(buffer);
        }


        function onERC721Received(
            address,
            address,
            uint256,
            bytes memory
        ) public virtual override returns (bytes4) {
            return this.onERC721Received.selector;
        }
    

        //FROM OZ WITH SLIGHT REWORK:
        function _checkOnERC721Received(address from, address to, uint256 tokenId, bytes memory _data)
            internal
            returns(bool)
        {
            if (isContract(to)) {
                try IERC721TokenReceiver(to).onERC721Received(msg.sender, from, tokenId, _data) returns (bytes4 retval) {
                    return retval == IERC721TokenReceiver.onERC721Received.selector;
                } catch (bytes memory reason) {
                    if (reason.length == 0) {
                        revert("ERC721: transfer to non ERC721Receiver implementer");
                    } else {
                        assembly {
                            revert(add(32, reason), mload(reason))
                        }
                    }
                }
            } else {
                return true;
            }
        }
    
    

    ////////////////////////////////////////////////
    //             OVERRIDABLE HOOKS              //
    ////////////////////////////////////////////////


        /**
         * @dev Hook that is called before any token transfer. This includes minting
         * and burning.
         *
         * Calling conditions:
         *
         * - When `from` and `to` are both non-zero, ``from``'s `tokenId` will be
         * transferred to `to`.
         * - When `from` is zero, `tokenId` will be minted for `to`.
         * - When `to` is zero, ``from``'s `tokenId` will be burned.
         * - `from` and `to` are never both zero.
         *
         * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
         */
        function _beforeTokenTransfer(
            address from,
            address to,
            uint256 tokenId
        ) internal virtual {}
        
        
}