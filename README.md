# FanLink
For the Chainlink Spring Hackathon 2022.

## Inspiration
As a musician, I am fascinated by the NFT art movement and keenly interested in how NFTs can be used to empower musicians and reduce reliance on the big monopolies of Spotify, Google Music, etc. Apart from NFT use-cases for things like copyright and royalty distribution, I think that how NFTs are a huge way to build communities - as proven by JPEG NFTs over the last year. 

So now that we know NFTs can be used in different ways to enable musicians to interact with their communities - I think a really cool aspect of crypto's interoperability is the ability for projects to interact with one another, so some sort of FanLink NFT could be just a building block in a larger Music NFT ecosystem. 

I also really like the idea of "vampire attacks" and was thinking about how music streaming is firmly dominated by Web2 - can we somehow vampire attack web2? OAuth seems like an open door to connect your web2 accounts securely to web3 and form that bridge into your web3 identity. 

I do appreciate that this is not too appropriate for every type of data - you don't want to mint an NFT and store personal identification information onchain that would dox yourself. However, certain classes of data like artist fandom can't really be linked back to an individual on its own so I view this use-case as okay. In addition, many people like to flaunt their fandom of their favorite artists so being on-chain and public can be seen as a benefit.

## What it does
FanLink is a project with a couple components. First is the ERC-1155 structure of the FanLink tokens themselves. These are soulbound NFTs, meaning they can't be transferred between addresses (I played WoW and love this name) and are meant to represent someone's fandom in their favorite artists. Someone would first sign-in to the frontend with their Spotify account - this allows the FE to get an OAuth access token and allow the FE to pull that person's favorite artists and mint those to an NFT. I also added an Update function to allow a fan to periodically add to their FanLink and add to their favorite artists - either by incrementing their old faves or adding new ones.

The second part is a set of Chainlinked Artist tools as a separate contract and section in the FE. This is the artist interaction tools that allow them to see their on-chain fans and interact with them in various ways like reimbursing them in ETH for the price of their last concert or airdrop ETH for the ticket price of an upcoming concert. 

## How we built it
I have two Solidity Contracts - one for the artist tools that implements Chainlink Price Feeds for ETH/USD and VRFv1 for the lottery and one for the FanLink ERC-1155 where I overrode the transfer functions so these tokens can't be transferred.

## Challenges we ran into
Realistically a couple things need to be added. I was close but didnt finish minting through a Chainlink External Adapter. Right now, anyone can simulate the data array from the Spotify API call and mint to the Solidity contract. They can also mint from a single Spotify Account to multiple wallets. Using a Chainlink EA, you could encrypt the Access token that was posted to the EA call, then decrypt that and make the Spotify API call from the EA. You could also store linkages of Spotify account ID to NFT ID or something similar to ensure 1:1.

I also didn't get a chance to implement VRFv2 which would have been fun but VRFv1 is a bit easier to use IMO.


## Requirements
Overall - 
1. I used VSCode, Brownie, and React. Install those. 
2. I also used Ganache-CLI for testing locally, install that.
3. I deployed and did integrated testing on Kovan with a couple different accounts.


## Setting Up And Deploying The Solidity Contracts
1. Open up VSCode and fill out your .env to set up your accounts on Kovan etc.
2. "brownie compile"
3. run in FanLinkNFT folder, to deploy FanLink.sol, run "brownie run scripts/deploy.py --network=kovan" to run an overall deployment script to Kovan.
4. run in ArtistToolsSOL folder, to deploy ArtistTools.sol, run "brownie run scripts/deploy.py --network=kovan" to run an overall deployment script to Kovan.
3a. Remember to fund the ArtistToolsSOL contract with LINK!
4. Now interact via Etherscan or the frontend. You can Create a New FAM, Add NFTs to open FAMs, or Finalize FAMs. Then to see the Keeper/EA interaction, move an added NFT between wallets to see the regenerated image.

## Setting up the Frontend
1. Change contract address variables to point to your FanLink and ArtistTools contracts deployed on Kovan. Add your Alchemy Key to a .env file (used in index.tsx as config with @usedapp)
2. You'll also need to sign up for a Spotify Dev account and make a new Spotify OAuth adapter with OAuth.io and get that key to plug into the configuration in the Frontend (in Header.js - or just use mine that i left in there).
3. You may need to regenerate the ABI jsons using: npx typechain --target ethers-v5 --out-dir src/abis/types './src/abis/*.json'
4. "yarn start" to run this on localhost.
5. Connect with Spotify
