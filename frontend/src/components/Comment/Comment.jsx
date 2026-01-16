import styles from "./Comment.module.css";

export function Comment({
  author,
  content,
  date,
  likes,
  setLikes,
  interest,
  setInterest,
  canModify,
}) {
  return (
    <div className={styles.comment}>
      <div className={styles.header}>
        <p className={styles.author}>{author}</p>
        <p className={styles.date}>{date}</p>

        {canModify && <button className={styles.modify}>Modify</button>}
      </div>

      <input className={styles.content} type="text" value={content} disabled />

      <div className={styles.footer}>
        <button onClick={() => setLikes(likes + 1)}>👍</button>
        <span>{likes}</span>

        <button onClick={() => setInterest(interest + 1)}>⭐</button>
        <span>{interest}</span>
      </div>
    </div>
  );
}
