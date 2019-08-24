import React, { Component } from 'react';
import styles from './Hero.module.scss';
import cx from 'classnames';
import logos from './pic_bg.png';

export default class Hero extends Component {
  renderLogo(name, imgUrl) {
    return (
      <div className={cx(styles.logo, styles[name])}>
        <img alt="zeppelin" className="logo-img" src={imgUrl} />
      </div>
    );
  }
  render() {
    return (
      <div className={styles.Hero}>
        <div>HERO</div>
      </div>
    );
  }
}
