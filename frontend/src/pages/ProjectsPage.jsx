import { Outlet } from "react-router-dom";
import { ProjectSummaryList } from "../components/ProjectSummaryList";
import { SearchPanel } from "../components/SearchPanel";
import styled from "styled-components";
import { Header } from "../components/Header";
import { useEffect, useState } from "react";
import { useFetchWithAuth } from "../utils/fetchData";

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

export function ProjectsPage() {
  const [projects, setProjects] = useState([]);
  const [loading, setLoading] = useState(true);
  const fetchWithAuth = useFetchWithAuth();

  const refetchData = async () => {
    try {
      const res = await fetchWithAuth("/Projects");
      if (res.ok) {
        const data = await res.json();
        setProjects(data);
      }
    } catch (error) {
      console.log("Failed to fetch projects", error);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    refetchData();
  }, []);

  return (
    <>
      <div>
        <Header />
        <StyledDisplaySection>
          <StyledInfoSection>
            <SearchPanel
              onNewsetClick={() => alert("Newest")}
              onTopClick={() => alert("top")}
              createPath={"/Projects/create"}
            />
            <ProjectSummaryList projects={projects} loading={loading} />
          </StyledInfoSection>
          <Outlet context={{ refreshSummary: refetchData }} />
        </StyledDisplaySection>
      </div>
    </>
  );
}
