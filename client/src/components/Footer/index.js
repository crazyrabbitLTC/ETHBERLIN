import React from 'react';
import styles from './footer.module.scss';
// import logo from './logo-red.png'
import mail from './mail.svg';
import twitter from './twitter.svg';
import github from './github.svg';
import zeppelin from './zeppelin_logo.png';

const Footer = () => (
  <footer className={styles.footer}>
    <div className={styles.brand}>
      <div className={styles.created}>Created by Dennison Bertram © 2019</div>
    </div>
    <div className={styles.links}>
      <a href="mailto:dennison@dennisonbertram.com" target="_blank" rel="noopener noreferrer">
        <img src={mail} alt="email" />
      </a>
      <a href="https://twitter.com/OpenZeppelin" rel="noopener noreferrer" target="_blank">
        <img src={twitter} alt="twitter" />
      </a>
      <a href="https://github.com/OpenZeppelin" rel="noopener noreferrer" target="_blank">
        <img src={github} alt="github" />
      </a>
    </div>
  </footer>
);

export default Footer;
