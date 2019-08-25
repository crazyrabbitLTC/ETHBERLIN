import React, { useState, useEffect } from 'react';
import styles from './SingleWord.module.scss';

const SingleWord = props => {
  const { adder, tribute, word, wordIndex } = props;

  return (
    <div className={styles.SingleWord}>
      <div className={styles.addressTribute}>
        <div className={styles.address}>{adder}</div>
        <div className={styles.tribute}>{tribute} WEI</div>
      </div>
      <div className={styles.wordDetail}>
        <div className={styles.index}>
          {/* <React.Fragment >#:</React.Fragment> */}[{wordIndex}]
        </div>
        <div className={styles.word}>{word}</div>
      </div>
    </div>
  );
};

export default SingleWord;
