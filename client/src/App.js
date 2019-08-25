import React, { useState } from 'react';

import { useWeb3Injected } from '@openzeppelin/network';

import Header from './components/Header';
import Footer from './components/Footer';
import InfoBar from './components/InfoBar';
import styles from './App.module.scss';

// const infuraToken = process.env.REACT_APP_INFURA_TOKEN;
//const infuraToken = '95202223388e49f48b423ea50a70e336';

function App() {
  const context = useWeb3Injected();

  // load Counter json artifact
  let wordDaoJson = undefined;
  try {
    wordDaoJson = require('../../contracts/WordDao.sol');
  } catch (e) {
    console.log(e);
  }

  // load WordDao instance
  const [WordDaoInstance, setWordDaoInstance] = useState(undefined);
  let deployedNetwork = undefined;
  if (!WordDaoInstance && context && wordDaoJson && wordDaoJson.networks && context.networkId) {
    deployedNetwork = wordDaoJson.networks[context.networkId.toString()];
    if (deployedNetwork) {
      const contract = new context.lib.eth.Contract(wordDaoJson.abi, deployedNetwork.address);
      setWordDaoInstance(contract);
    }
  }

  // function renderNoWeb3() {
  //   return (
  //     <div className={styles.loader}>
  //       <h3>Web3 Provider Not Found</h3>
  //       <p>Please, install and run Ganache.</p>
  //     </div>
  //   );
  // }

  return (
    <div className={styles.App}>
      <Header {...context} wordDaoInstance={WordDaoInstance} />
      <InfoBar {...context} wordDaoInstance={WordDaoInstance} />
      <Footer {...context} />
    </div>
  );
}

export default App;
