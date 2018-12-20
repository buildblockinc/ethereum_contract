pragma solidity ^0.4.23;

// Voting contract
contract VotingContract {

    address public owner;
    // Voting
    struct Voting{
        bool complete;
        uint approvalCount;
        uint rejectCount;
        uint targetCount;
        uint castedVotes;
        mapping(address => int8) decisions;    // 1: agree, 0: neutral, -1: disagree
        mapping(address => uint) votePower;
    }
    mapping(address => Voting[]) votemap;

    constructor() public {
        owner = msg.sender;
    }

    function createVoting(address productContractAddr, address[] voters, uint[] votersPower) public {
        require(msg.sender == owner);
        assert(voters.length == votersPower.length);
        Voting memory newVotingInstance = Voting({
            complete: false,
            approvalCount: 0,
            rejectCount: 0,
            targetCount: 0,
            castedVotes: 0
        });
        votemap[productContractAddr].push(newVotingInstance);

        Voting storage newVoting = votemap[productContractAddr][votemap[productContractAddr].length-1];
        for (uint i=0; i<voters.length; i++){
            newVoting.votePower[voters[i]] = votersPower[i];
            newVoting.targetCount += votersPower[i];
        }
    }

    function castVote(address productContractAddr, address voter, int8 decision) public {
        require(msg.sender == owner);
        Voting storage votingProduct = votemap[productContractAddr][votemap[productContractAddr].length-1];
        assert(!votingProduct.complete);
        assert(votingProduct.decisions[voter] == 0);
        assert(decision == 1 || decision == -1);
        votingProduct.decisions[voter] = decision;
        votingProduct.castedVotes += 1;
        if (decision == 1) votingProduct.approvalCount += votingProduct.votePower[voter];
        else votingProduct.rejectCount += votingProduct.votePower[voter];

        if (votingProduct.approvalCount + votingProduct.rejectCount == votingProduct.targetCount) votingProduct.complete = true;
    }

    function proxyVote(address productContractAddr, address[] voters, int8 decision) public {
        require(msg.sender == owner);
        Voting storage votingProduct = votemap[productContractAddr][votemap[productContractAddr].length-1];
        assert(!votingProduct.complete);
        assert(decision == 1 || decision == -1);
        for (uint v=0; v<voters.length; v++){
            assert(votingProduct.decisions[voters[v]] == 0);
        }
        for (uint i=0; i<voters.length; i++){
            votingProduct.decisions[voters[i]] = decision;
            votingProduct.castedVotes += 1;
            if (decision == 1) votingProduct.approvalCount += votingProduct.votePower[voters[i]];
            else votingProduct.rejectCount += votingProduct.votePower[voters[i]];
        }
        if (votingProduct.approvalCount + votingProduct.rejectCount == votingProduct.targetCount) votingProduct.complete = true;
    }

    function markComplete(address productContractAddr, uint round) public returns (bool){
        require(msg.sender == owner);
        Voting storage votingProduct = votemap[productContractAddr][round];
        votingProduct.complete = true;
        return votingProduct.complete;
    }

    function getCounts(address productContractAddr, uint round) public view returns (uint[3]) {
        Voting storage votingProduct = votemap[productContractAddr][round];
        return [votingProduct.approvalCount, votingProduct.rejectCount, votingProduct.targetCount];
    }

    function getNumberOfVotes(address productContractAddr, uint round) public view returns (uint) {
        return votemap[productContractAddr][round].castedVotes;
    }

    function getUserVote(address productContractAddr, uint round, address voter) public view returns (int8) {
        return votemap[productContractAddr][round].decisions[voter];
    }

    function isComplete(address productContractAddr, uint round) public view returns (bool){
        return votemap[productContractAddr][round].complete;
    }

    function numRounds(address productContractAddr) public view returns (uint){
        return votemap[productContractAddr].length;
    }

}
