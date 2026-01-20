import { PlusIcon } from "lucide-react";
import { useState } from "react";
import { useNavigate } from "react-router-dom";
import styled from "styled-components";

const StyledSearch = styled.div`
  display: flex;
  flex-direction: row;
  justify-content: space-evenly;
  align-items: center;
`;

const StyledButton = styled.button`
  border: 1px solid black;
  border-radius: 10px;
  min-height: 10px;
  min-width: 60px;
  background-color: greenyellow;
  color: blue;
`;

const StyledSearchBlock = styled.div`
  margin-top: 5px;
  border: 2px solid black;
  background-color: #1de4ebfb;
  min-height: 30px;
  padding: 10px;
`;

const StyledOptions = styled.div`
  display: flex;
  flex-direction: row;
  gap: 20px;
`;

export function SearchPanel({ onNewsetClick, onTopClick, createPath }) {
  const [fixedOption, setFixedOption] = useState(true);
  const navigate = useNavigate();

  return (
    <>
      <StyledSearchBlock>
        {fixedOption && (
          <StyledSearch>
            <StyledOptions>
              <StyledButton
                onClick={() => {
                  onNewsetClick();
                }}
              >
                Newest
              </StyledButton>
              <StyledButton
                onClick={() => {
                  onTopClick();
                }}
              >
                Top
              </StyledButton>
            </StyledOptions>
            <StyledButton
              onClick={() => {
                setFixedOption((prev) => !prev);
              }}
            >
              Search
            </StyledButton>
            <StyledButton
              onClick={() => {
                navigate(createPath);
              }}
            >
              <PlusIcon size={16} />
            </StyledButton>
          </StyledSearch>
        )}
        {!fixedOption && (
          <StyledButton
            onClick={() => {
              setFixedOption((prev) => !prev);
            }}
          >
            Search
          </StyledButton>
        )}
      </StyledSearchBlock>
    </>
  );
}
