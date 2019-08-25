import React, { useState, useEffect } from 'react';
import styles from './InfoBar.module.scss';
import SingleWord from './SingleWord';

const InfoBar = props => {
  const blockCount = 1000;
  const { wordDaoInstance, accounts, lib, connected } = props;
  const [state, setState] = useState([]);
  let unsubscribe;

  useEffect(() => {
    const load = async () => {
      await getAllWords();
      unsubscribe = await subscribeLogEvent(wordDaoInstance, 'wordAdded');
    };

    if (wordDaoInstance) {
      load();
    }
    if (unsubscribe) {
      return () => unsubscribe.unsubscribe();
    }
  }, [connected, wordDaoInstance]);

  const subscribeLogEvent = async (instance, eventName) => {
    const eventJsonInterface = lib.utils._.find(
      instance._jsonInterface,
      o => o.name === eventName && o.type === 'event',
    );

    const subscription = lib.eth.subscribe(
      'logs',
      {
        address: instance.options.address,
        topics: [eventJsonInterface.signature],
      },
      (error, result) => {
        if (!error) {
          getAllWords();
        }
      },
    );
    return subscription;
  };

  const getAllWords = async () => {
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
    getAllWords();
  }, [connected, wordDaoInstance]);

  console.log('The state: ', state);
  const listWords = state.map(obj => {
    return <SingleWord {...obj} />;
  });

  return <div className={styles.InfoBar}>{listWords}</div>;
};

export default InfoBar;
