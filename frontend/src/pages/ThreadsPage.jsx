import { Outlet } from "react-router-dom";
import { SearchPanel } from "../components/SearchPanel";
import styled from "styled-components";
import { Header } from "../components/Header";
import { ThreadSummaryList } from "../components/ThreadSummaryList";
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

export function ThreadsPage() {
  const [threads, setThreads] = useState([]);
  const [loading, setLoading] = useState(true);
  const fetchWithAuth = useFetchWithAuth();

  const refetchData = async () => {
    try {
      const res = await fetchWithAuth("/Threads");
      if (res.ok) {
        const data = await res.json();
        setThreads(data);
      }
    } catch (error) {
      console.log("Failed to fetch threads", error);
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
              createPath={"/Threads/create"}
            />
            <ThreadSummaryList threads={threads} loading={loading} />
          </StyledInfoSection>
          <Outlet context={{ refreshSummary: refetchData }} />
        </StyledDisplaySection>
      </div>
    </>
  );
}
