import React, { useState, useEffect } from 'react';
import styles from './InfoBar.module.scss';
import SingleWord from './SingleWord';

const InfoBar = props => {
  const blockCount = 1000;
  const { wordDaoInstance, accounts, lib, connected } = props;

  const [state, setState] = useState([]);

  const getAllMsg = async () => {
    let words = [];
    if (wordDaoInstance) {
      const currentblock = await lib.eth.getBlockNumber();

      const logs = await wordDaoInstance.getPastEvents('wordAdded', {
        fromBlock: currentblock - blockCount,
        toBlock: 'latest',
      });

      logs.forEach(el => {
        const { word, wordIndex, tribute, adder } = el.returnValues;
        words = [{ word, wordIndex, tribute, adder }, ...words];
      });
    }
    console.log('Words: ', words);
    setState(words);
  };

  useEffect(() => {
    getAllMsg();
  }, [connected, wordDaoInstance]);

  console.log('The state: ', state);
  const listWords = state.map(obj => {
    return (
      <div>
        <div>Word: {obj.word}</div>
        <div>Index: {obj.wordIndex}</div>
        <div>Tribute: {obj.tribute}</div>
        <div>Contributor: {obj.adder}</div>
      </div>
    );
  });

  return <div className={styles.InfoBar}>{listWords}</div>;
};

export default InfoBar;
