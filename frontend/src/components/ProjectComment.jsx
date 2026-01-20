import styled from "styled-components";
import {
  Heart,
  ThumbsUp,
  MessageSquareReply,
  SquarePen,
  Save,
  SquareX,
  Trash,
} from "lucide-react";
import { useState } from "react";
import TextareaAutosize from "react-textarea-autosize";
import { useAuth } from "../Context/AuthContext";

const iconSize = 24;

const StyledComment = styled.li`
  display: flex;
  flex-direction: column;
  width: 300px;
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

const StyledProjectContent = styled(TextareaAutosize)`
  border: 1px solid "black";
  border-radius: 5px;
  padding: 8px;
  width: 100%;
  font-family: inherit;
  font-size: 1rem;
  resize: none;
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

const StyledCommentFooter = styled.div`
  display: flex;
  flex-direction: row;
  justify-content: space-between;
  margin-top: 2px;
`;

const StyledCommentReplyBtn = styled.button`
  border: none;

  &:hover {
    color: green;
  }
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

export function ProjectComment({
  author,
  content,
  createDate,
  likes,
  interest,
  depth,
  likeSet,
  interestSet,
  onEditSubmit,
  onReplaySubmit,
  onDelete,
  canModify,
}) {
  const [modifyContent, setModifyContent] = useState(content);
  const [mofidyEnable, setModifyEnable] = useState(false);

  const [replay, setReplay] = useState(false);
  const [replayContent, setReplayContent] = useState("");

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

  function handleReplay() {
    setReplayContent("");
    setReplay(true);
  }

  function handleReplaySave() {
    onReplaySubmit(replayContent);
    setReplay(false);
  }

  function handleReplayCancel() {
    setReplayContent("");
    setReplay(false);
  }

  return (
    <>
      <StyledComment $depth={depth}>
        <StyledCommentHeader>
          <StyledAuthor>{author}</StyledAuthor>
          <StyledCommentHeaderOpt>
            <StyledCommentDate>{createDate}</StyledCommentDate>
            {canModify && !mofidyEnable && (
              <StyledCommentReplyBtn onClick={handleModify}>
                <SquarePen size={16} strokeWidth={2} />
              </StyledCommentReplyBtn>
            )}
            {(canModify || role == "admin") && (
              <StyledCommentReplyBtn onClick={onDelete}>
                <Trash size={16} strokeWidth={2} />
              </StyledCommentReplyBtn>
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
            <StyledCommentReplyBtn onClick={handleOnCancel}>
              <SquareX size={iconSize} strokeWidth={2} />
            </StyledCommentReplyBtn>
            <StyledCommentReplyBtn onClick={handleOnSave}>
              <Save size={iconSize} strokeWidth={2} />
            </StyledCommentReplyBtn>
          </StyledCommentFooter>
        )}
        {/* <StyledCommentContent>{content}</StyledCommentContent> */}

        <StyledCommentFooter>
          <StyledCommentReplyBtn onClick={handleReplay}>
            <MessageSquareReply size={16} strokeWidth={2} />
          </StyledCommentReplyBtn>
          <StyledCommentStats>
            {/* <Eye size={16} />
            <p>16</p> */}
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
      {replay && (
        <StyledComment $depth={depth}>
          <StyledProjectContent
            value={replayContent}
            onChange={(e) => setReplayContent(e.target.value)}
            // Library specific props:
            minRows={2}
            maxRows={20} // Optional: limits how far it grows before scrolling
          />

          <StyledCommentFooter>
            <StyledCommentReplyBtn onClick={handleReplayCancel}>
              <SquareX size={iconSize} strokeWidth={2} />
            </StyledCommentReplyBtn>
            <StyledCommentReplyBtn onClick={handleReplaySave}>
              <Save size={iconSize} strokeWidth={2} />
            </StyledCommentReplyBtn>
          </StyledCommentFooter>
        </StyledComment>
      )}
    </>
  );
}
