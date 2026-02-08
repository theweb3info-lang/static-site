// Auto-play next article audio after current finishes
// Article sequence mapping
const articleSequence = {
  '01-坂本龙马': '02-西乡隆盛',
  '02-西乡隆盛': '03-德川庆喜',
  '03-德川庆喜': '04-伊藤博文',
  '04-伊藤博文': '07-大久保利通',
  '07-大久保利通': null  // Last one
};

// Get current article number from URL
function getCurrentArticle() {
  const path = window.location.pathname;
  const match = path.match(/(\d+-[^\/]+)\.html/);
  return match ? match[1] : null;
}

// Get next article
function getNextArticle() {
  const current = getCurrentArticle();
  return current ? articleSequence[current] : null;
}

// Setup audio player with auto-advance
document.addEventListener('DOMContentLoaded', function() {
  const audioDiv = document.querySelector('.audio');
  if (!audioDiv) return;
  
  const current = getCurrentArticle();
  if (!current) return;
  
  const audioSrc = `../audio/zh/${current}.mp3`;
  const next = getNextArticle();
  
  // Replace link with audio player
  audioDiv.innerHTML = `
    <audio id="audioPlayer" controls style="width: 100%;">
      <source src="${audioSrc}" type="audio/mpeg">
      您的浏览器不支持音频播放。
    </audio>
    ${next ? '<div style="margin-top: 8px; font-size: 14px; color: #666;">播放完毕后将自动播放下一篇</div>' : ''}
  `;
  
  // Auto-play next article
  if (next) {
    const player = document.getElementById('audioPlayer');
    player.addEventListener('ended', function() {
      window.location.href = `${next}.html`;
    });
  }
});
