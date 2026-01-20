import { Bookmark, Eye, MessageSquare, ThumbsUp } from "lucide-react";
import styled from "styled-components";
import { getDateInfo } from "../utils/date";

const iconSize = 16;

const StyledCommentStatusBtn = styled.button`
  padding-top: 4px;
  border: none;
  color: transparent;
  background-color: transparent;
`;

const StyledStatSection = styled.div`
  display: flex;
  flex-direction: row;
  align-items: center;
  gap: 3px;
`;

const StyledFooterStats = styled.div`
  display: flex;
  flex-direction: row;
  justify-content: space-evenly;
  align-items: center;
  margin-top: 5px;
  gap: 10px;
`;

const StyledThreadSummary = styled.li`
  display: flex;
  flex-direction: column;
  border: 1px solid black;
`;

const StyledInforSection = styled.div`
  display: flex;
  flex-direction: row;
  justify-content: space-between;
  gap: 5px;
`;

const StyledAuthorSection = styled.div`
  display: flex;
  flex-direction: column;
  gap: 4px;
`;

const StyledTitle = styled.h2`
  font-size: 20px;
`;

const StyledAuthor = styled.h3`
  font-size: 16px;
`;

export function ThreadSummary({
  title,
  author,
  date,
  comments,
  views,
  likes,
  saves,
  setSave,
  setLike,
  onClick,
}) {
  return (
    <>
      <StyledThreadSummary onClick={() => onClick()}>
        <StyledInforSection>
          <StyledAuthorSection>
            <StyledTitle>{title}</StyledTitle>
            <StyledAuthor>{author}</StyledAuthor>
          </StyledAuthorSection>
          <p>{getDateInfo(date)}</p>
        </StyledInforSection>
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
      </StyledThreadSummary>
    </>
  );
}
