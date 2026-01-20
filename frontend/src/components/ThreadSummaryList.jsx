import styled from "styled-components";
import { ThreadSummary } from "./ThreadSummary";
import { NavLink } from "react-router-dom";
import { useEffect, useState } from "react";
import { useFetchWithAuth } from "../utils/fetchData";

const StyledList = styled.ul`
  display: flex;
  flex-direction: column;
  gap: 5px;
  justify-content: flex-start;
  max-width: 300px;
`;

const StyledNavLink = styled(NavLink)`
  text-decoration: none;
  color: inherit;
  font-family: inherit;

  &:active {
    font-weight: bold;
    color: #007bff;
  }

  &:hover {
    color: #0056b3;
  }
`;

export function ThreadSummaryList() {
  const [threads, setThreads] = useState([]);
  const [loading, setLoading] = useState(true);
  const fetchWithAuth = useFetchWithAuth();

  useEffect(() => {
    const getThreads = async () => {
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
    getThreads();
  }, []);

  if (loading) return <div>Loading projects...</div>;

  return (
    <>
      <StyledList>
        {threads.map((project) => (
          <StyledNavLink
            key={project.thread_id}
            to={`/Threads/${project.thread_id}`}
          >
            <ThreadSummary
              key={project.thread_id}
              title={project.title}
              author={project.author}
              date={project.create_date}
              comments={project.comments}
              views={project.views}
              likes={project.views}
              saves={project.saves}
              setLike={true}
              setSave={false}
            />
          </StyledNavLink>
        ))}
      </StyledList>
    </>
  );
}
