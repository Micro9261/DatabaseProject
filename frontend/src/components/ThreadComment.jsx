import styled from "styled-components";
import { Heart, ThumbsUp, SquarePen, SquareX, Save, Trash } from "lucide-react";
import { useState } from "react";
import TextareaAutosize from "react-textarea-autosize";
import { useAuth } from "../Context/AuthContext";

const StyledComment = styled.li`
  display: flex;
  flex-direction: column;
  width: 800px;
  border: 1px solid gray;
  background-color: white;
  padding: 12px;
  border-radius: 5px;
  margin-left: ${({ $depth }) => $depth * 20}px;
`;

const StyledCommentHeader = styled.div`
  display: flex;
  flex-direction: row;
  justify-content: space-between;
`;

const StyledAuthor = styled.p`
  color: blue;
`;

const StyledCommentHeaderOpt = styled.div`
  display: flex;
  flex-direction: row;
  gap: 10px;
`;

const StyledCommentDate = styled.p`
  color: grey;
`;

const StyledCommentModifyBtn = styled.button`
  border: none;

  &:hover {
    color: green;
  }
`;

const StyledCommentContent = styled.p`
  min-height: 50px;
  border: 1px solid gray;
  border-radius: 10px;
  padding: 2px;
  box-shadow: 1px 2px 2px black;
`;

const StyledCommentFooter = styled.div`
  display: flex;
  flex-direction: row;
  justify-content: space-between;
  margin-top: 2px;
`;

const StyledCommentStats = styled.div`
  display: flex;
  flex-direction: row;
  gap: 5px;
  margin-top: 4px;
  justify-content: space-evenly;
  align-items: baseline;
`;

const StyledCommentStatusBtn = styled.button`
  border: none;
  color: transparent;
`;

const StyledProjectContent = styled(TextareaAutosize)`
  border: 1px solid "black";
  border-radius: 5px;
  padding: 8px;
  width: 100%;
  font-family: inherit;
  font-size: 1rem;
  resize: none; /* The library handles height, so we disable manual resize */
  background-color: transparent;
  min-height: 50px;
  display: block;
  box-sizing: border-box;
  color: black;

  &:focus {
    outline: none;
    border-color: "green";
  }
`;

export function ThreadComment({
  author,
  content,
  createDate,
  likes,
  interest,
  likeSet,
  interestSet,
  onEditSubmit,
  onDelete,
  canModify,
}) {
  const [modifyContent, setModifyContent] = useState(content);
  const [mofidyEnable, setModifyEnable] = useState(false);

  const { getUserData } = useAuth();
  let role = null;

  if (getUserData().role !== undefined) {
    role = getUserData().role;
  }

  function handleModify() {
    setModifyEnable(true);
  }

  function handleOnSave() {
    onEditSubmit(modifyContent);
    setModifyEnable(false);
  }

  function handleOnCancel() {
    setModifyContent(content);
    setModifyEnable(false);
  }
  return (
    <>
      <StyledComment $depth={0}>
        <StyledCommentHeader>
          <StyledAuthor>{author}</StyledAuthor>
          <StyledCommentHeaderOpt>
            <StyledCommentDate>{createDate}</StyledCommentDate>
            {canModify && (
              <StyledCommentModifyBtn onClick={handleModify}>
                <SquarePen size={16} strokeWidth={2} />
              </StyledCommentModifyBtn>
            )}
            {(canModify || role == "admin") && (
              <StyledCommentModifyBtn onClick={onDelete}>
                <Trash size={16} strokeWidth={2} />
              </StyledCommentModifyBtn>
            )}
          </StyledCommentHeaderOpt>
        </StyledCommentHeader>
        <StyledProjectContent
          readOnly={!mofidyEnable}
          value={modifyContent}
          onChange={(e) => setModifyContent(e.target.value)}
          // Library specific props:
          minRows={2}
          maxRows={20} // Optional: limits how far it grows before scrolling
        />
        {mofidyEnable && (
          <StyledCommentFooter>
            <StyledCommentModifyBtn onClick={handleOnCancel}>
              <SquareX size={24} strokeWidth={2} />
            </StyledCommentModifyBtn>
            <StyledCommentModifyBtn onClick={handleOnSave}>
              <Save size={24} strokeWidth={2} />
            </StyledCommentModifyBtn>
          </StyledCommentFooter>
        )}
        {/* <StyledCommentContent>{content}</StyledCommentContent> */}

        <StyledCommentFooter>
          <StyledCommentStats>
            <StyledCommentStatusBtn>
              <ThumbsUp size={16} fill={likeSet ? "blue" : ""} />
            </StyledCommentStatusBtn>
            <p>{likes}</p>
            <StyledCommentStatusBtn>
              <Heart size={16} fill={interestSet ? "red" : ""} />
            </StyledCommentStatusBtn>
            <p>{interest}</p>
          </StyledCommentStats>
        </StyledCommentFooter>
      </StyledComment>
    </>
  );
}
