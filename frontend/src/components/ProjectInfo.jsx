import styled from "styled-components";
import {
  Bookmark,
  Eye,
  MessageSquare,
  MessageSquareReply,
  Save,
  SquarePen,
  SquareX,
  ThumbsUp,
} from "lucide-react";
import { getDateInfo } from "../utils/date";
import { useAuth } from "../Context/AuthContext";
import { useState } from "react";
import TextareaAutosize from "react-textarea-autosize";

const iconSize = 24;

const StyledCommentStatusBtn = styled.button`
  padding-top: 4px;
  border: none;
  color: transparent;
  background-color: transparent;
`;

const StyledCommentReplyBtn = styled.button`
  border: none;
  background-color: transparent;

  &:hover {
    color: green;
  }
`;

const StyledProjectBlock = styled.div`
  display: flex;
  flex-direction: column;
  border: 2px solid green;
  border-radius: 5px;
  padding: 5px;
  min-width: 800px;
`;

const StyledHeader = styled.div`
  display: flex;
  flex-direction: row;
  justify-content: space-between;
`;

const StyledHeaderSummary = styled.div`
  display: flex;
  flex-direction: column;
  min-height: 100px;
`;

const StyledFooter = styled.div`
  display: flex;
  flex-direction: row;
  justify-content: space-between;
  align-items: baseline;
`;

const StyledFooterOptions = styled.div`
  display: flex;
  flex-direction: row;
  gap: 10px;
`;

const StyledFooterStats = styled.div`
  display: flex;
  flex-direction: row;
  justify-content: space-evenly;
  align-items: center;
  margin-top: 5px;
  gap: 10px;
`;

// const StyledProjectContent = styled.p`
//   border: 1px solid black;
//   border-radius: 5px;
//   min-height: 50px;
// `;

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

const StyledStatSection = styled.div`
  display: flex;
  flex-direction: row;
  align-items: center;
  gap: 3px;
`;

export function ProjectInfo({
  author,
  title,
  date,
  content,
  views,
  likes,
  saves,
  setLike,
  setSave,
  comments,
  onEditSubmit,
  onReplaySubmit,
}) {
  const [modifyContent, setModifyContent] = useState(content);
  const [mofidyEnable, setModifyEnable] = useState(false);

  const [replay, setReplay] = useState(false);
  const [replayContent, setReplayContent] = useState("");

  const { getUserData } = useAuth();
  let login = null;

  if (getUserData().login !== undefined) {
    login = getUserData().login;
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
      {" "}
      <StyledProjectBlock>
        <StyledHeader>
          <StyledHeaderSummary>
            <h1>{title}</h1>
            <h2>{author}</h2>
          </StyledHeaderSummary>
          <p>{getDateInfo(date)}</p>
        </StyledHeader>

        <StyledProjectContent
          readOnly={!mofidyEnable}
          value={modifyContent}
          onChange={(e) => setModifyContent(e.target.value)}
          // Library specific props:
          minRows={2}
          maxRows={20} // Optional: limits how far it grows before scrolling
        />

        {mofidyEnable && (
          <StyledFooterOptions>
            <StyledCommentReplyBtn onClick={handleOnSave}>
              <Save size={iconSize} strokeWidth={2} />
            </StyledCommentReplyBtn>
            <StyledCommentReplyBtn onClick={handleOnCancel}>
              <SquareX size={iconSize} strokeWidth={2} />
            </StyledCommentReplyBtn>
          </StyledFooterOptions>
        )}
        <StyledFooter>
          <StyledFooterOptions>
            <StyledCommentReplyBtn onClick={handleReplay}>
              <MessageSquareReply size={iconSize} strokeWidth={2} />
            </StyledCommentReplyBtn>
            {author == login && !mofidyEnable && (
              <StyledCommentReplyBtn onClick={handleModify}>
                <SquarePen size={iconSize} strokeWidth={2} />
              </StyledCommentReplyBtn>
            )}
          </StyledFooterOptions>
          <StyledFooterStats>
            <StyledStatSection>
              <MessageSquare size={iconSize} strokeWidth={2} />
              <p>{comments}</p>
            </StyledStatSection>
            <StyledStatSection>
              <Eye size={iconSize} strokeWidth={2} />
              <p>{views}</p>
            </StyledStatSection>
            <StyledStatSection>
              <StyledCommentStatusBtn>
                <ThumbsUp size={iconSize} fill={setLike ? "blue" : ""} />
              </StyledCommentStatusBtn>
              <p>{likes}</p>
            </StyledStatSection>
            <StyledStatSection>
              <StyledCommentStatusBtn>
                <Bookmark size={iconSize} fill={setSave ? "gold" : ""} />
              </StyledCommentStatusBtn>
              <p>{saves}</p>
            </StyledStatSection>
          </StyledFooterStats>
        </StyledFooter>
      </StyledProjectBlock>
      {replay && (
        <StyledProjectBlock>
          <StyledProjectContent
            value={replayContent}
            onChange={(e) => setReplayContent(e.target.value)}
            // Library specific props:
            minRows={2}
            maxRows={20} // Optional: limits how far it grows before scrolling
          />

          <StyledFooterOptions>
            <StyledCommentReplyBtn onClick={handleReplaySave}>
              <Save size={iconSize} strokeWidth={2} />
            </StyledCommentReplyBtn>
            <StyledCommentReplyBtn onClick={handleReplayCancel}>
              <SquareX size={iconSize} strokeWidth={2} />
            </StyledCommentReplyBtn>
          </StyledFooterOptions>
        </StyledProjectBlock>
      )}
    </>
  );
}
