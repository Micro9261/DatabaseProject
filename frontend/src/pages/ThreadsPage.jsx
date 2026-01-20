import { Outlet } from "react-router-dom";
import { SearchPanel } from "../components/SearchPanel";
import styled from "styled-components";
import { Header } from "../components/Header";
import { ThreadSummaryList } from "../components/ThreadSummaryList";

const StyledInfoSection = styled.div`
  display: flex;
  flex-direction: column;
  justify-content: flex-start;
  gap: 10px;
`;

const StyledDisplaySection = styled.div`
  display: flex;
  flex-direction: row;
  gap: 10px;
`;

export function ThreadsPage() {
  return (
    <>
      <div>
        <Header />
        <StyledDisplaySection>
          <StyledInfoSection>
            <SearchPanel
              onNewsetClick={() => alert("Newest")}
              onTopClick={() => alert("top")}
              createPath={"/Threads/create"}
            />
            <ThreadSummaryList />
          </StyledInfoSection>
          <Outlet />
        </StyledDisplaySection>
      </div>
    </>
  );
}
