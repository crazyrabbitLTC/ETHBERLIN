import React, { useState, useEffect } from 'react';
import styles from './InfoBar.module.scss';

const InfoBar = props => {
  const blockCount = 1000;
  const { wordDaoInstance, accounts, lib } = props;

  const [state, setState] = useState([]);

  const getAllMsg = async () => {
    let words = [];
    const currentblock = await lib.eth.getBlockNumber();
    const logs = await chatAppInstance.getPastEvents('wordAdded', {
      fromBlock: currentblock - blockCount,
      toBlock: 'latest',
    });

    logs.forEach(el => {
      const { word, wordIndex, tribute, adder } = el.returnValues;
      words = [{ word, wordIndex, tribute, adder }, ...words];
    });

    console.log('Words: ', words);
    setState(words);
  };

  useEffect(() => {
    getAllMsg();
  }, []);
  return (
    <div className={styles.InfoBar}>
      <div>InfoBar</div>
    </div>
  );
};

export default InfoBar;
