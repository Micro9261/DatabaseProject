import styled from "styled-components";
import { Header } from "../components/Header";
import { ProjectSummaryList } from "../components/ProjectSummaryList";
import { ThreadSummaryList } from "../components/ThreadSummaryList";
import { useAuth } from "../Context/AuthContext";
import { useEffect, useState } from "react";
import { createFetchWithAuth, useFetchWithAuth } from "../utils/fetchData";

const StyledContent = styled.div`
  display: flex;
  flex-direction: row;
  justify-content: center;
  margin: 20px;
  gap: 30px;
`;

export function MainPage() {
  const { getUserData } = useAuth();
  const [threads, setThreads] = useState([]);
  const [loadingThreads, setLoadingThreads] = useState(true);
  const fetchWithAuth = useFetchWithAuth();

  const [projects, setProjects] = useState([]);
  const [loadingProjects, setLoadingProjects] = useState(true);

  const refetchData = async () => {
    try {
      const resThreads = await fetchWithAuth("/Threads");
      const resProjects = await fetchWithAuth("/Projects");
      if (resThreads.ok && resProjects.ok) {
        const dataThreads = await resThreads.json();
        const dataProjects = await resProjects.json();
        setThreads(dataThreads);
        setProjects(dataProjects);
      }
    } catch (error) {
      console.log("Failed to fetch threads", error);
    } finally {
      setLoadingThreads(false);
      setLoadingProjects(false);
    }
  };

  useEffect(() => {
    refetchData();
  }, []);

  console.log(getUserData());
  return (
    <div>
      <Header />
      <StyledContent>
        <ProjectSummaryList projects={projects} loading={loadingProjects} />
        <ThreadSummaryList threads={threads} loading={loadingThreads} />
      </StyledContent>
    </div>
  );
}
