import React, { useState, useEffect } from 'react';
import styles from './SingleWord.module.scss';

const SingleWord = props => {
  const { adder, tribute, word, wordIndex } = props;

  return (
    <div className={styles.SingleWord}>
      <div>{word}</div>
      <div>{adder}</div>
      <div>{tribute}</div>
      <div>{wordIndex}</div>
    </div>
  );
};

export default SingleWord;
