'use strict';

{
  function setWord() {
    num = Math.floor(Math.random() * words.length);

    word = words.splice(num, 1)[0];
    text = texts.splice(num, 1)[0];
    
    target.textContent = word;
    label.textContent = text;
    loc = 0;
  }

  const wordsbase = [
    'kaidousikiyuugiki', 
    // 'surottomasi-nn',
    // 'yamanotesen',
    // 'toukyoutonerimaku',
  ];
  const textsbase = [
    "回胴式遊技機",
    // "スロットマシーン",
    // "山手線",
    // "東京都練馬区",
  ];

  let words;
  let texts;

  function setArray() {
    words = Array.from(wordsbase);
    texts = Array.from(textsbase);
  }

  let num;
  let word;
  let text;
  let loc = 0;
  let startTime;
  let isPlaying = false;
  const target = document.getElementById('target');
  const label = document.getElementById('label');

  document.getElementById('backtype').style.display = 'none';

  function startTyping() { 
    if (isPlaying === true) {
      return;
    }
    
    isPlaying = true;
    startTime = Date.now();
    setArray();
    setWord();
  }

  // タイピング開始のトリガー
  document.addEventListener('click', () => {
    startTyping();
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
        target.textContent = "";

        document.getElementById('backtype').style.display = 'inline';
        return;
      }

      setWord();
    }
  });

  document.getElementById("backtype").onclick = function() {
    // document.getElementById("target").innerHTML = "クリックされた！";
    isPlaying = false;
    document.getElementById('backtype').style.display = 'none';

    startTyping();
  };

  function myfunc() {
  }
}