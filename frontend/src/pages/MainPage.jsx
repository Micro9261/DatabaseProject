import styled from "styled-components";
import { Header } from "../components/Header";
import { ProjectSummaryList } from "../components/ProjectSummaryList";
import { ThreadSummaryList } from "../components/ThreadSummaryList";
import { useAuth } from "../Context/AuthContext";

const StyledContent = styled.div`
  display: flex;
  flex-direction: row;
  justify-content: center;
  margin: 20px;
  gap: 30px;
`;

export function MainPage() {
  const { getUserData } = useAuth();

  console.log(getUserData());
  return (
    <div>
      <Header />
      <StyledContent>
        <ProjectSummaryList />
        <ThreadSummaryList />
      </StyledContent>
    </div>
  );
}
