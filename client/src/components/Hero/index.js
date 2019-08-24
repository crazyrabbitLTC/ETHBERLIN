import React, { useState, useEffect } from 'react';
import styles from './Hero.module.scss';
import cx from 'classnames';
import { Field, Input } from 'rimble-ui';
import WordForm from './WordForm';

function Hero(props) {
  console.log('Props: ', props);

  const defaultSigState = {
    word: '',
    signature: '',
  };

  const [signature, setSignature] = useState(defaultSigState);

  return (
    <div className={styles.Hero}>
      <WordForm {...props} />
    </div>
  );
}

export default Hero;
