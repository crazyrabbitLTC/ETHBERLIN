import React, { useState } from 'react';

import { useWeb3Network, useEphemeralKey, useWeb3Injected } from '@openzeppelin/network';
import Header from './components/Header/index.js';
import Footer from './components/Footer/index.js';
import Hero from './components/Hero/index.js';
import Web3Info from './components/Web3Info/index.js';
import Counter from './components/Counter/index.js';

import styles from './App.module.scss';

// const infuraToken = process.env.REACT_APP_INFURA_TOKEN;
const infuraToken = '95202223388e49f48b423ea50a70e336';

function App() {
  const context = useWeb3Injected();

  console.log('Context: ', context);
  // load Counter json artifact
  let wordDaoJson = undefined;
  try {
    wordDaoJson = require('../../contracts/WordDao.sol');
    console.log('WordDao json', wordDaoJson);
  } catch (e) {
    console.log(e);
  }

  // load WordDao instance
  const [WordDaoInstance, setWordDaoInstance] = useState(undefined);
  let deployedNetwork = undefined;
  if (!WordDaoInstance && context && wordDaoJson && wordDaoJson.networks && context.networkId) {
    deployedNetwork = wordDaoJson.networks[context.networkId.toString()];
    console.log('Deployed Network:', deployedNetwork);
    if (deployedNetwork) {
      console.log('wordDaoJson.abi: ', wordDaoJson.abi, 'deployedNetwork.address: ', deployedNetwork.address);
      const contract = new context.lib.eth.Contract(wordDaoJson.abi, deployedNetwork.address);
      setWordDaoInstance(contract);
      console.log('WordDao instance', contract);
    }
  }

  function renderNoWeb3() {
    return (
      <div className={styles.loader}>
        <h3>Web3 Provider Not Found</h3>
        <p>Please, install and run Ganache.</p>
      </div>
    );
  }

  return (
    <div className={styles.App}>
      <div>Welcome to WordDao!</div>
    </div>
  );
}

export default App;
