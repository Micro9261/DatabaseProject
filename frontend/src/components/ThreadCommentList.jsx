import styled from "styled-components";
import { ThreadComment } from "./ThreadComment";
import { getDateInfo } from "../utils/date";
import { useAuth } from "../Context/AuthContext";

const StyledList = styled.ul`
  display: flex;
  flex-direction: column;
  gap: 5px;
`;

export function ThreadCommentList({ commentsList, onEdit }) {
  const { getUserData } = useAuth();
  let login = null;
  if (getUserData().login !== undefined) {
    login = getUserData().login;
  }
  return (
    <StyledList>
      {commentsList.map((comment) => {
        return (
          <ThreadComment
            key={comment.comment_id}
            author={comment.author}
            content={comment.content}
            createDate={getDateInfo(comment.create_date)}
            likes={comment.likes}
            interest={comment.interest}
            likeSet={comment.set_like}
            interestSet={comment.set_interest}
            onEditSubmit={(content) => onEdit(comment.comment_id, content)}
            onReplaySubmit={() => alert("onReplay submit")}
            canModify={login == comment.author}
          />
        );
      })}
    </StyledList>
  );
}
