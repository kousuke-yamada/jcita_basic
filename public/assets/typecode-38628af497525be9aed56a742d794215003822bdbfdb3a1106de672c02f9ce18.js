'use strict';

{
  const wordsbase = [
    'neko',
    'pasokonn',
    'memori-',
    'dhisupurei',
    'ki-bo-do',
    'migikurikku',
    'dengennonn', 
    // 'surottomasi-nn',
    // 'yamanotesen',
    // 'toukyoutonerimaku',
  ];
  const textsbase = [
    "猫",
    "パソコン",
    "メモリー",
    "ディスプレイ",
    "キーボード",
    "右クリック",
    "電源オン",
  ];

  const wordsbase_h = [
    "huri-ennginianinaru",
  ];
  const textsbase_h = [
    'フリーエンジニアになる',    
  ];

  const wordsbase_c = [
    "nekohunzyatta",
  ];
  const textsbase_c = [
    '猫踏んじゃった',
  ];

  let words;
  let texts;

  let num;
  let word;
  let text;
  let loc = 0;
  let startTime;
  let isPlaying = false;
  let target = document.getElementById('target');
  let label = document.getElementById('label');
  // let best = document.getElementById('best');
  let prescore = 999.99;

  document.getElementById('backtype').style.display = 'none';

  const mode = Number(document.getElementById('mode').value);
  const user_id = Number(document.getElementById('user_id').value);
  const best_record = Number(document.getElementById('best_record').value);

  // カウントダウンタイマー関連
  // const timer = document.getElementById('timer');
  const btn = document.getElementById('btn');
  let endTime;
  let intervalId;
  let isStarting = false;


  window.onload = function(){
    // ページ読み込み時に実行したい処理
    document.getElementById('target').reset();
    document.getElementById('label').reset();
    prescore = 999.99;
  }

  // 汎用関数
  function myfunc() {
  }
  // タイピング問題用の配列セット
  function setArray() {

    switch(mode){
      case 1:   // Easyモード
        words = Array.from(wordsbase);
        texts = Array.from(textsbase);
        break;

      case 2:   // Hardモード
        words = Array.from(wordsbase_h);
        texts = Array.from(textsbase_h);
        break;
      
      case 3:   // 猫モード
        words = Array.from(wordsbase_c);
        texts = Array.from(textsbase_c);
        break;
      
      default:
        // Easyモードを設定しておく
        words = Array.from(wordsbase);
        texts = Array.from(textsbase);
        break;
    }
  } 
  // タイピング問題のラベル・テキストの設定
  function setWord() {
    num = Math.floor(Math.random() * words.length);

    word = words.splice(num, 1)[0];
    text = texts.splice(num, 1)[0];
    
    target.style.color = "#000000";
    target.textContent = word;
    label.textContent = text;
    // best.textContent = "　";
    loc = 0;
  }
  // カウントダウン開始
  function startCountDown() {
    if( isStarting === true){
      return;
    }
    label.textContent = "　";
    isStarting = true;

    document.getElementById('backtype').style.display = 'none';
    document.getElementById('sel_mode').style.display = 'none';
    document.getElementById('chk_score').style.display = 'none';
    label.textContent ="　";
    target.textContent = "　";

    // (1) 終了時刻を求める
    endTime = new Date().getTime() + 3 * 1000;

    // (2) 残り時間を求める
    intervalId = setInterval(check, 100);
  }
  // タイピング開始時の処理
  function startTyping() { 
    if (isPlaying === true) {
      return;
    }
    
    document.getElementById('backtype').style.display = 'none';
    isPlaying = true;
    startTime = Date.now();
    setArray();
    setWord();
  }

  // タイピング開始のトリガー
  document.addEventListener('keydown', e => {
    if (e.code === "Space") {      
      startCountDown();
    }
  });
  
  // タイピング中の動作
  document.addEventListener('keydown', e => {
    if (e.key !== word[loc]) {
      return;
    }
    
    loc++;

    target.textContent = '_'.repeat(loc) + word.substring(loc);

    // 最終文字まで到達したら次のワードへ
    if ( loc === word.length) {
      if ( words.length === 0){
        const elapsedTime = ((Date.now() - startTime) / 1000).toFixed(2);
        label.textContent = `Finished! ${elapsedTime} seconds!`;
        target.textContent = "　";
        
        // もう一回ボタン押した時に「BEST SCORE!!」と出さないための処理
        if ( elapsedTime < prescore){
          prescore = elapsedTime;
        }        
        
        if ( elapsedTime < best_record){
          if ( elapsedTime <= prescore ){
            target.style.color = "#ff0000";
            target.textContent = "🐈 BEST SCORE!! 🐈";
          }
        }

        document.getElementById('backtype').style.display = "inline";
        document.getElementById('sel_mode').style.display = "inline";
        document.getElementById('chk_score').style.display = "inline";


        $.ajax({
          type: 'patch',
          url: `/users/${user_id}/save_record`,
          data: { record: elapsedTime, mode: mode },
          dataType: 'json'
        })

        return;
      }

      setWord();
    }
  });

  document.getElementById("backtype").onclick = function() {

    isStarting = false;
    // isPlaying = false;
    // isStarting = false;
    // document.getElementById('backtype').style.display = 'none';
    // label.textContent ="";
    // best.textContent = "";

    startCountDown();
  };

  // カウントダウンタイマー処理
  function check() {
    // 残り時間 = 終了時刻 - 現在時刻
    let countdown = endTime - new Date().getTime();

    // (3) タイマーの終了
    if (countdown < 0) {
      clearInterval(intervalId);
      countdown = 3 * 1000;

      label.textContent = "　";
      isPlaying = false;
      startTyping();
      return;
    }

    const totalSeconds = Math.floor(countdown / 1000);
    // 80秒 → 1分20秒
    // 80 ÷ 60 = 1 余り 20
    // 80 / 60 = 1.33333.... → 1
    // 80 % 60 = 20
    const minutes = Math.floor(totalSeconds / 60);
    const seconds = totalSeconds % 60 + 1;

    const minutesFormatted = String(minutes).padStart(2, '0');
    const secondsFormatted = String(seconds).padStart(1, '0');

    label.textContent = `😺 開始まで ${secondsFormatted}秒 😺`;
    // label.textContent = `${minutesFormatted}:${secondsFormatted}`;
  }
  
  
  // document.addEventListener('keydown', e => {
  //   if (e.code === "Enter") {
  //     // (1) 終了時刻を求める
  //     endTime = new Date().getTime() + 3 * 1000;

  //     // (2) 残り時間を求める
  //     intervalId = setInterval(check, 100);
  //     }
  // });
  
}
;
