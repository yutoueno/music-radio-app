"""add_playback_session_and_track_play

Revision ID: a3d7f9e1b4c6
Revises: 96587b1e8a23
Create Date: 2026-04-01 15:00:00.000000

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql

# revision identifiers, used by Alembic.
revision: str = 'a3d7f9e1b4c6'
down_revision: Union[str, None] = '96587b1e8a23'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.create_table('playback_sessions',
    sa.Column('id', postgresql.UUID(as_uuid=True), nullable=False),
    sa.Column('user_id', postgresql.UUID(as_uuid=True), nullable=False),
    sa.Column('program_id', postgresql.UUID(as_uuid=True), nullable=False),
    sa.Column('current_position_seconds', sa.Float(), nullable=False, server_default='0'),
    sa.Column('is_completed', sa.Boolean(), nullable=False, server_default='false'),
    sa.Column('updated_at', sa.DateTime(timezone=True), server_default=sa.text('now()'), nullable=False),
    sa.Column('created_at', sa.DateTime(timezone=True), server_default=sa.text('now()'), nullable=False),
    sa.ForeignKeyConstraint(['user_id'], ['users.id'], ondelete='CASCADE'),
    sa.ForeignKeyConstraint(['program_id'], ['programs.id'], ondelete='CASCADE'),
    sa.PrimaryKeyConstraint('id')
    )
    op.create_index(op.f('ix_playback_sessions_user_id'), 'playback_sessions', ['user_id'], unique=False)
    op.create_index(op.f('ix_playback_sessions_program_id'), 'playback_sessions', ['program_id'], unique=False)

    op.create_table('track_plays',
    sa.Column('id', postgresql.UUID(as_uuid=True), nullable=False),
    sa.Column('program_id', postgresql.UUID(as_uuid=True), nullable=False),
    sa.Column('track_id', postgresql.UUID(as_uuid=True), nullable=False),
    sa.Column('user_id', postgresql.UUID(as_uuid=True), nullable=True),
    sa.Column('created_at', sa.DateTime(timezone=True), server_default=sa.text('now()'), nullable=False),
    sa.ForeignKeyConstraint(['program_id'], ['programs.id'], ondelete='CASCADE'),
    sa.ForeignKeyConstraint(['track_id'], ['program_tracks.id'], ondelete='CASCADE'),
    sa.ForeignKeyConstraint(['user_id'], ['users.id'], ondelete='SET NULL'),
    sa.PrimaryKeyConstraint('id')
    )
    op.create_index(op.f('ix_track_plays_program_id'), 'track_plays', ['program_id'], unique=False)
    op.create_index(op.f('ix_track_plays_track_id'), 'track_plays', ['track_id'], unique=False)
    op.create_index(op.f('ix_track_plays_user_id'), 'track_plays', ['user_id'], unique=False)


def downgrade() -> None:
    op.drop_index(op.f('ix_track_plays_user_id'), table_name='track_plays')
    op.drop_index(op.f('ix_track_plays_track_id'), table_name='track_plays')
    op.drop_index(op.f('ix_track_plays_program_id'), table_name='track_plays')
    op.drop_table('track_plays')
    op.drop_index(op.f('ix_playback_sessions_program_id'), table_name='playback_sessions')
    op.drop_index(op.f('ix_playback_sessions_user_id'), table_name='playback_sessions')
    op.drop_table('playback_sessions')
