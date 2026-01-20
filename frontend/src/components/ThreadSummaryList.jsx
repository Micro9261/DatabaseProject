import styled from "styled-components";
import { ThreadSummary } from "./ThreadSummary";
import { NavLink } from "react-router-dom";

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

export function ThreadSummaryList({ threads = [], loading }) {
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
              likes={project.likes}
              saves={project.saves}
              setLike={false}
              setSave={false}
            />
          </StyledNavLink>
        ))}
      </StyledList>
    </>
  );
}
