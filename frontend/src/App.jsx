import { Comment } from "./components/Comment/Comment";
import "./App.css";

function App() {
  return (
    <>
      <Comment
        author={"test"}
        content={"contentTest"}
        date={"12-14-2025"}
        likes={24}
        setLikes={false}
        interest={10}
        setInterest={false}
        canModify={true}
      />
      <Comment
        author={"test"}
        content={"contentTest"}
        date={"12-14-2025"}
        likes={24}
        setLikes={false}
        interest={10}
        setInterest={false}
        canModify={true}
      />
      <Comment
        author={"test"}
        content={"contentTest"}
        date={"12-14-2025"}
        likes={24}
        setLikes={false}
        interest={10}
        setInterest={false}
        canModify={true}
      />
    </>
  );
}

export default App;
