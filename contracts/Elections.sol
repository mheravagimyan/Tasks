// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import "./ShareHolders.sol";

/**
 * @title IShareHolders
 * @dev Via this interface send the memebrs their share 
 */
interface IShareHolders {
    function addPartner(address _addr, uint _percentage) external;
}

/**
 * @title Elections
 * @dev this contract create an Elections and gives chance to participate in it,
 * every members will receive corresponding amount of ETH depending on the number of votes.
 * Everyone can vote just once and cant change the choice. Each members can add own participation
 * just once and remove it before the votes will start.
 */
contract Elections {
    address owner;
    uint start;
    uint electionTime;
    uint membersTime;
    uint priceToBeMember;
    uint votes;
    address[] member;

    //capture the current state
    enum State {
        Pending,
        Active,
        Executed
    }

    
    mapping(address => bool) voters;    //to know who voted
    mapping(address => uint) membersVotes;  //to know how many votes members have
    mapping(address => bool) members;   //to know who became a member


    modifier onlyOwner() {
        require(msg.sender == owner, "Elections: Not an owner!");
        _;
    }

    /**
     * @dev create contract with initial args
     * @param _priceToBeMember the amount of ETH to be memebr
     * @param _membersTime the time that users could become a member
     * @param _electionTime the time that election can continue
     */
    constructor(uint _priceToBeMember, uint _membersTime, uint _electionTime) {
        owner = msg.sender;
        priceToBeMember = _priceToBeMember;
        electionTime = _electionTime;
        membersTime = _membersTime;
        start = block.timestamp;
    }

    /**
     * @dev to become a member just once before votes starting, if you have enough funds
     */
    function becomeMember() external payable {
        require(
            state() == State.Pending,
            "Time to be become a member has expired!"
        );
        require(msg.value >= priceToBeMember, "Not enough funds to be member!");
        require(!members[msg.sender], "You already member!");
        members[msg.sender] = true;
        member.push(msg.sender);
    }

    /**
     * @dev to choose member just once via index, during the votes period
     * @param _numberOfMember members index in list
     */
    function chooseMember(uint _numberOfMember) external {
        require(state() == State.Active, "No time to vote or it has expired!");
        require(!voters[msg.sender], "You already vote!");
        require(
            _numberOfMember < member.length,
            "There is no member with this number!"
        );
        voters[msg.sender] = true;
        membersVotes[member[_numberOfMember]]++;
        votes++;
    }

    /**
     * @dev to send members share if the election is over
     * @param _shareAddress the ShareHolders contract address 
     */
    function finishElection(address _shareAddress) external onlyOwner {
        require(state() == State.Executed, "The elections arent over!");
        for (uint i; i < member.length; i++) {
            IShareHolders(_shareAddress).addPartner(
                member[i],
                (membersVotes[member[i]] * 100) / votes
            );
        }

        (bool sent, ) = _shareAddress.call{value: address(this).balance}("");

        require(sent, "Election: Faild");
    }

    /**
     * @dev to get current state about election
     * @return state of election
     */
    function state() public view returns (State) {
        if (block.timestamp <= start + membersTime) {
            return State.Pending;
        } else if (
            block.timestamp > start + membersTime &&
            block.timestamp <= start + membersTime + electionTime
        ) {
            return State.Active;
        } else {
            return State.Executed;
        }
    }

    /**
     * @dev Could remove own participation from election before the votes start
     */
    function removeFromElection() external {
        require(members[msg.sender] == true, "You arent member!");
        require(
            state() == State.Pending,
            "Time to remove participation in election has expired!"
        );

        delete members[msg.sender];
        deleteParticipation();
    }

    /**
     * @dev to get members
     * @return members of election
     */
    function getMembers() external view returns (address[] memory) {
        return member;
    }

    /**
     * @dev to get the memebers votes in the current situation
     * @return amount of votes
     */
    function getCurrentSituation(address _addr) external view returns (uint) {
        require(members[_addr] == true, "There isnt member with this address!");

        return membersVotes[_addr];
    }

    /**
     * @dev delete memebr from election
     */
    function deleteParticipation() private {
        for (uint i; i < member.length; i++) {
            if (member[i] == msg.sender) {
                member[i] = member[member.length - 1];
                member.pop();
                return;
            }
        }
    }
}
