import React, { useState, useEffect } from 'react';
import axios from 'axios';
import styles from './Hero.module.scss';
import cx from 'classnames';
import logos from './pic_bg.png';

function Hero(props) {
  console.log('Props: ', props);

  const defaultSigState = {
    word: '',
    signature: '',
  };
  const [signature, setSignature] = useState(defaultSigState);

  const getSignature = word => {
    const fetch = async word => {
      axios.get(`http://localhost:3000/${word}`).then(res => {
        const signature = res.data;
        setSignature({ word, signature });
        console.log('Word: ', word, ' Signature: ', signature);
      });
    };
  };

  return (
    <div className={styles.Hero}>
      <div>HERO</div>
    </div>
  );
}

export default Hero;
