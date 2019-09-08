[![Coverage Status](https://coveralls.io/repos/github/crazyrabbitLTC/ETHBERLIN/badge.svg?branch=master)](https://coveralls.io/github/crazyrabbitLTC/ETHBERLIN?branch=master)

# ETHBERLIN

ETH BERLIN Hackathon Project

## Inspiration

Words (string type data objects) are currently prohibitively expensive to store on the Ethereum Blockchain. This means smart contracts can not affordably be string-aware, store large amounts of on-chain data or interact directly very easily with strings. WordDao fixes this problem by created a single central Map of all words on chain where they can be reference by integer (\_int) data types at a tremendous gas savings.

There is a master list of ~450,000 english words which would be impossibly expensive to store on-chain for any one individual.

For WordDao we ask the community to sponsor the gas-cost of storing a word on-chain, along with a small tribute (to prevent abuse). In exchange the sponsor is given an ERC20 compatible token called "WordToken".

Users are then able to sponsor the creation of additional utilities to make using strings on ethereum more practical. Smart contracts, when interacting with the WordDao library are required to pay a small fee for each contract call- a fee which is returned to the pool and which the users are able to vote to disburse.

## What it does

WordDao is a type of Contribution Based Cooperative. Users collectively pay the fee required to build public infrastructure, along with a small tribute to go into a pool. This pool is then collectively managed by the users holding the ERC20 token and is expected to pay for the development of additional String Libraries to interface with WordDao.

The WordDao, if it votes wisely, will create utility libraries which will generate a profit. This profit users are free to return to themselves or to reinvest.

## How I built it

The current form of the application supports External DAO's as decision making entities. The current version of the DAO is upgradable and the upgrade mechanism can be owned by an External DAO.

The WordDao is coded in Solidity and Javascript. It is deployed on Rinkeby.

## Challenges I ran into

I have tried to build this project several times in the past, but it was necessary for me to start over for this hackathon and create an entirely new codebase.
To prevent spam and gibberish attacks it was necessary to pre-sign all english language words with a private-key. This created a large file and it was not practical to include this file in the React Front end. This required me to build a separate Express server to serve an API with signatures for words.

## Accomplishments that I'm proud of

This is a project I have been wanting to tackle for sometime now. I am very proud that single handedly I could get the code to the point where there is an attractive front end, and a functional backend (it is necessary for many functions to call them directly from OpenZeppelin SDK or Truffle Console).

## What I learned

It was necessary to learn about signing, building express server, and learning about the existing common DAO's. It was a difficult project especially as a one-man team with limited time. I focused on being interoperable with external DAO's to save myself time from needing to code a DAO this weekend. The front end was designed to be artractive while the backend solidity code is fully functional.

## What's next for WordDao

This is a MVP but I believe highly in the idea and it's utility for setting a precedent on how we can fund public infrastructure. While this project deals with primarily strings- it could be used to store on chain large data-sets: rainbow tables for example, which might have a use for smart contracts on chain. It is a unique idea, and a fun way to encourage participation in governance organziations, while creating potentially profitable and productive tool.
