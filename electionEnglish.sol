// SPDX-License-Identifier: MIT 
pragma solidity ^0.8.7;

contract Election {
    
    struct Voter {
        bool voted;  //When voter vote, we will update this. If 1, the citizen voted, if 0, he did not.
        uint votedFor; //Here we'll keep which candidate voter voted for. (as an index)
    }

    struct Candidate {
        string name; //We will keep the candidate's name.
        uint totalVote; //We will keep the votes received here.
    }

    mapping(address=>Voter) public voters; //Here, the address of each voter will keep the Voting Structure.

    Candidate[] public candidates; //We created an array to hold the Candidate structure.
    address public contractStarter; //We've defined this in order to keep the address that calls the Smart Contract.
    
    constructor(string[] memory candidateNames) { //Here we've defined a constructor for us to enter the name of the candidates when the Smart Contract is called.
        contractStarter = msg.sender; //We keep the address that calls the Smart Contract under the name of contractStarter.
        for(uint i = 0 ; i < candidateNames.length ; i++) { //After the names are entered, we throw the name of each candidate 
            candidates.push(Candidate({name: candidateNames[i], totalVote: 0})); //who will be kept in our array thanks to this loop.
        }                                                             
    }

     modifier onlyOneVote() { //In this modifier, we impose a condition with the help of require 
        Voter storage voter = voters[msg.sender]; //for each voter to vote only once.
        
        require(!voter.voted, "The vote has been cast, you cannot cast another vote!");
        _;
    }

     function voting(uint preferred) external onlyOneVote {
        require(contractStarter != msg.sender, "Invalid vote!"); //We are doing this because I do not want the address that initiated the agreement to be authorized to vote.
        
        Voter storage voter = voters[msg.sender]; //We want every voter to make the transaction himself.
        voter.voted = true; //If it is the first time to vote, we update the voted to true.
        voter.votedFor = preferred; //Here we discard who the voter voted for.
        candidates[preferred].totalVote++; //Here we update the total number of votes received by the candidate voted for by the voter.
     }

     function electionWinner() external view returns(string memory winnerCandidate) {
        uint moreVotes = 0; //We will use this when comparing candidates. We will equalize the vote of the candidate who received more votes to this.
        
        for(uint i = 0 ; i < candidates.length ; i++){ //Here I used a for loop to compare the candidates.
            
            if(candidates[i].totalVote > moreVotes){ //Here I used an (if) that compares the number of votes received decisively between the candidates.
                moreVotes = candidates[i].totalVote; //If the candidate we compare is more than the number of votes of the candidate who updated moreVotes, we update moreVotes again.
                winnerCandidate = candidates[i].name; //We are also updating the candidate's name until a candidate with more votes emerges.
            }
        }
    }

}