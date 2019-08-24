import React from 'react';
import styles from './header.module.scss';

const Header = () => (
  <div className={styles.header}>
    <nav id="menu" className="menu">
      <div className={styles.brand}>
        <div className={styles.blackText}>WordDao</div>
      </div>
    </nav>
  </div>
);

export default Header;
