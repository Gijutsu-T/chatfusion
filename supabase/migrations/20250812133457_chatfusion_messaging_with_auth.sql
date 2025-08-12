-- Location: supabase/migrations/20250812133457_chatfusion_messaging_with_auth.sql
-- Schema Analysis: Fresh project - creating complete chat application schema
-- Integration Type: Complete new module
-- Dependencies: None - creating full messaging system with authentication

-- 1. Types and Enums
CREATE TYPE public.user_role AS ENUM ('admin', 'moderator', 'member');
CREATE TYPE public.message_type AS ENUM ('text', 'image', 'file', 'voice', 'video', 'location', 'emoji', 'document', 'sticker');
CREATE TYPE public.chat_type AS ENUM ('direct', 'group', 'channel');
CREATE TYPE public.message_status AS ENUM ('sent', 'delivered', 'read');
CREATE TYPE public.user_status AS ENUM ('online', 'away', 'busy', 'offline');

-- 2. Core Tables

-- Critical intermediary table for PostgREST compatibility
CREATE TABLE public.user_profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id),
    email TEXT NOT NULL UNIQUE,
    username TEXT UNIQUE,
    full_name TEXT NOT NULL,
    avatar_url TEXT,
    bio TEXT,
    phone TEXT,
    status public.user_status DEFAULT 'offline'::public.user_status,
    is_online BOOLEAN DEFAULT false,
    last_seen TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    role public.user_role DEFAULT 'member'::public.user_role,
    is_active BOOLEAN DEFAULT true,
    notification_settings JSONB DEFAULT '{"push": true, "email": true, "desktop": true}'::jsonb,
    privacy_settings JSONB DEFAULT '{"read_receipts": true, "last_seen": true, "profile_photo": true}'::jsonb,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Chats table (supports direct, group, and channels)
CREATE TABLE public.chats (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    chat_type public.chat_type NOT NULL DEFAULT 'direct'::public.chat_type,
    name TEXT, -- null for direct chats, required for groups/channels
    description TEXT,
    avatar_url TEXT,
    created_by UUID REFERENCES public.user_profiles(id) ON DELETE SET NULL,
    is_archived BOOLEAN DEFAULT false,
    is_muted BOOLEAN DEFAULT false,
    is_pinned BOOLEAN DEFAULT false,
    member_count INTEGER DEFAULT 0,
    max_members INTEGER DEFAULT 1000,
    invite_link TEXT UNIQUE,
    settings JSONB DEFAULT '{}'::jsonb,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Chat members/participants
CREATE TABLE public.chat_members (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    chat_id UUID REFERENCES public.chats(id) ON DELETE CASCADE,
    user_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    role public.user_role DEFAULT 'member'::public.user_role,
    joined_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    is_admin BOOLEAN DEFAULT false,
    is_moderator BOOLEAN DEFAULT false,
    can_send_messages BOOLEAN DEFAULT true,
    can_add_members BOOLEAN DEFAULT false,
    can_edit_info BOOLEAN DEFAULT false,
    notifications_enabled BOOLEAN DEFAULT true,
    UNIQUE(chat_id, user_id)
);

-- Messages table
CREATE TABLE public.messages (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    chat_id UUID REFERENCES public.chats(id) ON DELETE CASCADE,
    sender_id UUID REFERENCES public.user_profiles(id) ON DELETE SET NULL,
    parent_message_id UUID REFERENCES public.messages(id) ON DELETE SET NULL, -- For replies
    content TEXT,
    message_type public.message_type DEFAULT 'text'::public.message_type,
    file_url TEXT,
    file_name TEXT,
    file_size BIGINT,
    file_type TEXT,
    thumbnail_url TEXT,
    metadata JSONB DEFAULT '{}'::jsonb, -- For storing additional data like location coords, etc.
    is_edited BOOLEAN DEFAULT false,
    edit_count INTEGER DEFAULT 0,
    is_deleted BOOLEAN DEFAULT false,
    is_pinned BOOLEAN DEFAULT false,
    reactions JSONB DEFAULT '{}'::jsonb, -- Store emoji reactions count
    mentions UUID[], -- Array of user IDs mentioned
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Message status tracking (delivery, read receipts)
CREATE TABLE public.message_status (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    message_id UUID REFERENCES public.messages(id) ON DELETE CASCADE,
    user_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    status public.message_status DEFAULT 'sent'::public.message_status,
    timestamp TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(message_id, user_id)
);

-- Message reactions (Discord-like)
CREATE TABLE public.message_reactions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    message_id UUID REFERENCES public.messages(id) ON DELETE CASCADE,
    user_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    emoji TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(message_id, user_id, emoji)
);

-- Blocked users
CREATE TABLE public.blocked_users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    blocker_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    blocked_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(blocker_id, blocked_id)
);

-- User device tokens for push notifications
CREATE TABLE public.user_devices (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    device_token TEXT NOT NULL,
    device_type TEXT NOT NULL, -- 'ios', 'android', 'web'
    device_name TEXT,
    is_active BOOLEAN DEFAULT true,
    last_used TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- 3. Storage Buckets
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES 
    ('avatars', 'avatars', true, 5242880, ARRAY['image/jpeg', 'image/png', 'image/webp', 'image/jpg']),
    ('chat-files', 'chat-files', false, 52428800, ARRAY['image/jpeg', 'image/png', 'image/webp', 'image/jpg', 'video/mp4', 'video/mov', 'audio/mp3', 'audio/wav', 'audio/m4a', 'application/pdf', 'application/msword', 'application/vnd.openxmlformats-officedocument.wordprocessingml.document']),
    ('voice-messages', 'voice-messages', false, 10485760, ARRAY['audio/mp3', 'audio/wav', 'audio/m4a', 'audio/ogg']);

-- 4. Essential Indexes
CREATE INDEX idx_user_profiles_email ON public.user_profiles(email);
CREATE INDEX idx_user_profiles_username ON public.user_profiles(username);
CREATE INDEX idx_user_profiles_is_online ON public.user_profiles(is_online);
CREATE INDEX idx_chats_created_by ON public.chats(created_by);
CREATE INDEX idx_chats_chat_type ON public.chats(chat_type);
CREATE INDEX idx_chat_members_chat_id ON public.chat_members(chat_id);
CREATE INDEX idx_chat_members_user_id ON public.chat_members(user_id);
CREATE INDEX idx_messages_chat_id ON public.messages(chat_id);
CREATE INDEX idx_messages_sender_id ON public.messages(sender_id);
CREATE INDEX idx_messages_created_at ON public.messages(created_at DESC);
CREATE INDEX idx_messages_parent_message_id ON public.messages(parent_message_id);
CREATE INDEX idx_message_status_message_id ON public.message_status(message_id);
CREATE INDEX idx_message_status_user_id ON public.message_status(user_id);
CREATE INDEX idx_message_reactions_message_id ON public.message_reactions(message_id);
CREATE INDEX idx_blocked_users_blocker_id ON public.blocked_users(blocker_id);
CREATE INDEX idx_blocked_users_blocked_id ON public.blocked_users(blocked_id);
CREATE INDEX idx_user_devices_user_id ON public.user_devices(user_id);

-- 5. RLS Setup
ALTER TABLE public.user_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.chats ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.chat_members ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.message_status ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.message_reactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.blocked_users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_devices ENABLE ROW LEVEL SECURITY;
ALTER TABLE storage.objects ENABLE ROW LEVEL SECURITY;

-- 6. Helper Functions
CREATE OR REPLACE FUNCTION public.is_chat_member(chat_uuid UUID, user_uuid UUID)
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
SELECT EXISTS (
    SELECT 1 FROM public.chat_members cm
    WHERE cm.chat_id = chat_uuid AND cm.user_id = user_uuid
)
$$;

CREATE OR REPLACE FUNCTION public.is_blocked_user(user_uuid UUID, blocked_uuid UUID)
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
SELECT EXISTS (
    SELECT 1 FROM public.blocked_users bu
    WHERE bu.blocker_id = user_uuid AND bu.blocked_id = blocked_uuid
)
$$;

-- 7. RLS Policies

-- Pattern 1: Core user table (user_profiles)
CREATE POLICY "users_manage_own_user_profiles"
ON public.user_profiles
FOR ALL
TO authenticated
USING (id = auth.uid())
WITH CHECK (id = auth.uid());

-- Public read access for user profiles (needed for chat functionality)
CREATE POLICY "authenticated_users_read_profiles"
ON public.user_profiles
FOR SELECT
TO authenticated
USING (true);

-- Pattern 2: Simple user ownership for chats
CREATE POLICY "users_manage_own_chats"
ON public.chats
FOR ALL
TO authenticated
USING (created_by = auth.uid())
WITH CHECK (created_by = auth.uid());

-- Chat members can view chats they belong to
CREATE POLICY "chat_members_view_chats"
ON public.chats
FOR SELECT
TO authenticated
USING (public.is_chat_member(id, auth.uid()));

-- Pattern 2: Simple user ownership for chat members
CREATE POLICY "users_manage_own_chat_members"
ON public.chat_members
FOR ALL
TO authenticated
USING (user_id = auth.uid())
WITH CHECK (user_id = auth.uid());

-- Chat creators can manage members
CREATE POLICY "chat_creators_manage_members"
ON public.chat_members
FOR ALL
TO authenticated
USING (
    EXISTS (
        SELECT 1 FROM public.chats c
        WHERE c.id = chat_id AND c.created_by = auth.uid()
    )
)
WITH CHECK (
    EXISTS (
        SELECT 1 FROM public.chats c
        WHERE c.id = chat_id AND c.created_by = auth.uid()
    )
);

-- Messages: Chat members can view and send messages
CREATE POLICY "chat_members_view_messages"
ON public.messages
FOR SELECT
TO authenticated
USING (public.is_chat_member(chat_id, auth.uid()));

CREATE POLICY "chat_members_create_messages"
ON public.messages
FOR INSERT
TO authenticated
WITH CHECK (
    public.is_chat_member(chat_id, auth.uid()) 
    AND sender_id = auth.uid()
);

CREATE POLICY "users_update_own_messages"
ON public.messages
FOR UPDATE
TO authenticated
USING (sender_id = auth.uid())
WITH CHECK (sender_id = auth.uid());

CREATE POLICY "users_delete_own_messages"
ON public.messages
FOR DELETE
TO authenticated
USING (sender_id = auth.uid());

-- Pattern 2: Simple user ownership for message status
CREATE POLICY "users_manage_own_message_status"
ON public.message_status
FOR ALL
TO authenticated
USING (user_id = auth.uid())
WITH CHECK (user_id = auth.uid());

-- Message senders can view status of their messages
CREATE POLICY "message_senders_view_status"
ON public.message_status
FOR SELECT
TO authenticated
USING (
    EXISTS (
        SELECT 1 FROM public.messages m
        WHERE m.id = message_id AND m.sender_id = auth.uid()
    )
);

-- Pattern 2: Simple user ownership for reactions
CREATE POLICY "users_manage_own_reactions"
ON public.message_reactions
FOR ALL
TO authenticated
USING (user_id = auth.uid())
WITH CHECK (user_id = auth.uid());

-- Chat members can view reactions in their chats
CREATE POLICY "chat_members_view_reactions"
ON public.message_reactions
FOR SELECT
TO authenticated
USING (
    EXISTS (
        SELECT 1 FROM public.messages m
        WHERE m.id = message_id AND public.is_chat_member(m.chat_id, auth.uid())
    )
);

-- Pattern 2: Simple user ownership for blocked users
CREATE POLICY "users_manage_own_blocked_users"
ON public.blocked_users
FOR ALL
TO authenticated
USING (blocker_id = auth.uid())
WITH CHECK (blocker_id = auth.uid());

-- Pattern 2: Simple user ownership for devices
CREATE POLICY "users_manage_own_devices"
ON public.user_devices
FOR ALL
TO authenticated
USING (user_id = auth.uid())
WITH CHECK (user_id = auth.uid());

-- Storage Policies

-- Users can view own avatars
CREATE POLICY "users_view_own_avatars"
ON storage.objects
FOR SELECT
TO authenticated
USING (bucket_id = 'avatars' AND owner = auth.uid());

-- Public can view all avatars (for chat functionality)
CREATE POLICY "public_view_avatars"
ON storage.objects
FOR SELECT
TO public
USING (bucket_id = 'avatars');

-- Users can upload own avatars
CREATE POLICY "users_upload_own_avatars"
ON storage.objects
FOR INSERT
TO authenticated
WITH CHECK (
    bucket_id = 'avatars'
    AND owner = auth.uid()
    AND (storage.foldername(name))[1] = auth.uid()::text
);

-- Users can update/delete own avatars
CREATE POLICY "users_manage_own_avatars"
ON storage.objects
FOR UPDATE
TO authenticated
USING (bucket_id = 'avatars' AND owner = auth.uid())
WITH CHECK (bucket_id = 'avatars' AND owner = auth.uid());

CREATE POLICY "users_delete_own_avatars"
ON storage.objects
FOR DELETE
TO authenticated
USING (bucket_id = 'avatars' AND owner = auth.uid());

-- Chat files policies
CREATE POLICY "chat_members_view_files"
ON storage.objects
FOR SELECT
TO authenticated
USING (
    bucket_id IN ('chat-files', 'voice-messages')
    AND EXISTS (
        SELECT 1 FROM public.messages m
        WHERE m.file_url LIKE '%' || name
        AND public.is_chat_member(m.chat_id, auth.uid())
    )
);

CREATE POLICY "authenticated_users_upload_files"
ON storage.objects
FOR INSERT
TO authenticated
WITH CHECK (
    bucket_id IN ('chat-files', 'voice-messages')
    AND owner = auth.uid()
);

CREATE POLICY "users_manage_own_files"
ON storage.objects
FOR UPDATE
TO authenticated
USING (bucket_id IN ('chat-files', 'voice-messages') AND owner = auth.uid())
WITH CHECK (bucket_id IN ('chat-files', 'voice-messages') AND owner = auth.uid());

CREATE POLICY "users_delete_own_files"
ON storage.objects
FOR DELETE
TO authenticated
USING (bucket_id IN ('chat-files', 'voice-messages') AND owner = auth.uid());

-- 8. Functions for automatic profile creation
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER
SECURITY DEFINER
LANGUAGE plpgsql
AS $$
DECLARE
    username_base TEXT;
    unique_username TEXT;
    counter INTEGER := 1;
BEGIN
    -- Extract username from email
    username_base := split_part(NEW.email, '@', 1);
    unique_username := username_base;
    
    -- Ensure username uniqueness
    WHILE EXISTS (SELECT 1 FROM public.user_profiles WHERE username = unique_username) LOOP
        unique_username := username_base || counter::TEXT;
        counter := counter + 1;
    END LOOP;
    
    INSERT INTO public.user_profiles (
        id, 
        email, 
        username, 
        full_name, 
        role
    )
    VALUES (
        NEW.id, 
        NEW.email, 
        unique_username,
        COALESCE(NEW.raw_user_meta_data->>'full_name', unique_username),
        COALESCE(NEW.raw_user_meta_data->>'role', 'member')::public.user_role
    );
    
    RETURN NEW;
END;
$$;

-- Function to update last_seen and online status
CREATE OR REPLACE FUNCTION public.update_user_activity(user_uuid UUID)
RETURNS VOID
SECURITY DEFINER
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE public.user_profiles 
    SET 
        last_seen = CURRENT_TIMESTAMP,
        is_online = true,
        updated_at = CURRENT_TIMESTAMP
    WHERE id = user_uuid;
END;
$$;

-- Function to get direct chat between two users
CREATE OR REPLACE FUNCTION public.get_or_create_direct_chat(user1_uuid UUID, user2_uuid UUID)
RETURNS UUID
SECURITY DEFINER
LANGUAGE plpgsql
AS $$
DECLARE
    chat_uuid UUID;
BEGIN
    -- Find existing direct chat
    SELECT c.id INTO chat_uuid
    FROM public.chats c
    JOIN public.chat_members cm1 ON c.id = cm1.chat_id AND cm1.user_id = user1_uuid
    JOIN public.chat_members cm2 ON c.id = cm2.chat_id AND cm2.user_id = user2_uuid
    WHERE c.chat_type = 'direct' AND c.member_count = 2;
    
    -- Create new direct chat if not exists
    IF chat_uuid IS NULL THEN
        INSERT INTO public.chats (chat_type, member_count, created_by)
        VALUES ('direct', 2, user1_uuid)
        RETURNING id INTO chat_uuid;
        
        -- Add both users as members
        INSERT INTO public.chat_members (chat_id, user_id)
        VALUES 
            (chat_uuid, user1_uuid),
            (chat_uuid, user2_uuid);
    END IF;
    
    RETURN chat_uuid;
END;
$$;

-- Trigger for new user creation
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- Trigger to update chat member count
CREATE OR REPLACE FUNCTION public.update_chat_member_count()
RETURNS TRIGGER
SECURITY DEFINER
LANGUAGE plpgsql
AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        UPDATE public.chats 
        SET member_count = member_count + 1 
        WHERE id = NEW.chat_id;
        RETURN NEW;
    ELSIF TG_OP = 'DELETE' THEN
        UPDATE public.chats 
        SET member_count = member_count - 1 
        WHERE id = OLD.chat_id;
        RETURN OLD;
    END IF;
    RETURN NULL;
END;
$$;

CREATE TRIGGER update_chat_member_count_trigger
    AFTER INSERT OR DELETE ON public.chat_members
    FOR EACH ROW EXECUTE FUNCTION public.update_chat_member_count();

-- Trigger to update updated_at timestamps
CREATE OR REPLACE FUNCTION public.update_updated_at_column()
RETURNS TRIGGER
SECURITY DEFINER
LANGUAGE plpgsql
AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$;

CREATE TRIGGER update_user_profiles_updated_at
    BEFORE UPDATE ON public.user_profiles
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_chats_updated_at
    BEFORE UPDATE ON public.chats
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_messages_updated_at
    BEFORE UPDATE ON public.messages
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

-- 9. Mock Data
DO $$
DECLARE
    user1_auth_id UUID := gen_random_uuid();
    user2_auth_id UUID := gen_random_uuid();
    user3_auth_id UUID := gen_random_uuid();
    user4_auth_id UUID := gen_random_uuid();
    direct_chat_id UUID := gen_random_uuid();
    group_chat_id UUID := gen_random_uuid();
    design_team_id UUID := gen_random_uuid();
BEGIN
    -- Create auth users with required fields
    INSERT INTO auth.users (
        id, instance_id, aud, role, email, encrypted_password, email_confirmed_at,
        created_at, updated_at, raw_user_meta_data, raw_app_meta_data,
        is_sso_user, is_anonymous, confirmation_token, confirmation_sent_at,
        recovery_token, recovery_sent_at, email_change_token_new, email_change,
        email_change_sent_at, email_change_token_current, email_change_confirm_status,
        reauthentication_token, reauthentication_sent_at, phone, phone_change,
        phone_change_token, phone_change_sent_at
    ) VALUES
        (user1_auth_id, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated',
         'sarah.johnson@email.com', crypt('password123', gen_salt('bf', 10)), now(), now(), now(),
         '{"full_name": "Sarah Johnson"}'::jsonb, '{"provider": "email", "providers": ["email"]}'::jsonb,
         false, false, '', null, '', null, '', '', null, '', 0, '', null, null, '', '', null),
        (user2_auth_id, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated',
         'michael.chen@email.com', crypt('password123', gen_salt('bf', 10)), now(), now(), now(),
         '{"full_name": "Michael Chen"}'::jsonb, '{"provider": "email", "providers": ["email"]}'::jsonb,
         false, false, '', null, '', null, '', '', null, '', 0, '', null, null, '', '', null),
        (user3_auth_id, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated',
         'emma.rodriguez@email.com', crypt('password123', gen_salt('bf', 10)), now(), now(), now(),
         '{"full_name": "Emma Rodriguez"}'::jsonb, '{"provider": "email", "providers": ["email"]}'::jsonb,
         false, false, '', null, '', null, '', '', null, '', 0, '', null, null, '', '', null),
        (user4_auth_id, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated',
         'david.kim@email.com', crypt('password123', gen_salt('bf', 10)), now(), now(), now(),
         '{"full_name": "David Kim"}'::jsonb, '{"provider": "email", "providers": ["email"]}'::jsonb,
         false, false, '', null, '', null, '', '', null, '', 0, '', null, null, '', '', null);

    -- Create chats
    INSERT INTO public.chats (id, chat_type, name, description, created_by, member_count) VALUES
        (direct_chat_id, 'direct', null, null, user1_auth_id, 2),
        (group_chat_id, 'group', 'Project Alpha', 'Main project discussion group', user1_auth_id, 3),
        (design_team_id, 'group', 'Design Team', 'Creative team collaboration', user2_auth_id, 4);

    -- Add chat members
    INSERT INTO public.chat_members (chat_id, user_id, is_admin) VALUES
        -- Direct chat between Sarah and Michael
        (direct_chat_id, user1_auth_id, false),
        (direct_chat_id, user2_auth_id, false),
        
        -- Project Alpha group
        (group_chat_id, user1_auth_id, true), -- Sarah as admin
        (group_chat_id, user2_auth_id, false),
        (group_chat_id, user3_auth_id, false),
        
        -- Design Team group
        (design_team_id, user1_auth_id, false),
        (design_team_id, user2_auth_id, true), -- Michael as admin
        (design_team_id, user3_auth_id, false),
        (design_team_id, user4_auth_id, false);

    -- Create sample messages
    INSERT INTO public.messages (chat_id, sender_id, content, message_type) VALUES
        (direct_chat_id, user1_auth_id, 'Hey! How''s your day going? I was thinking we could grab coffee later if you''re free.', 'text'),
        (direct_chat_id, user2_auth_id, 'Sounds great! I''m free after 3 PM. Where would you like to meet?', 'text'),
        (direct_chat_id, user1_auth_id, 'How about that new cafe downtown? I heard they have amazing coffee.', 'text'),
        
        (group_chat_id, user3_auth_id, 'Meeting scheduled for tomorrow at 2 PM', 'text'),
        (group_chat_id, user1_auth_id, 'Perfect! I''ll prepare the presentation slides.', 'text'),
        (group_chat_id, user2_auth_id, 'Great, I''ll bring the project timeline documents.', 'text'),
        
        (design_team_id, user2_auth_id, 'Alex shared the new mockups for the mobile app redesign project', 'document'),
        (design_team_id, user4_auth_id, 'The new design looks incredible! Love the color scheme.', 'text'),
        (design_team_id, user1_auth_id, 'Campaign results are looking great! Revenue increased by 25%', 'text'),
        (design_team_id, user3_auth_id, 'Fantastic work everyone! 🎉', 'text');

EXCEPTION
    WHEN foreign_key_violation THEN
        RAISE NOTICE 'Foreign key error: %', SQLERRM;
    WHEN unique_violation THEN
        RAISE NOTICE 'Unique constraint error: %', SQLERRM;
    WHEN OTHERS THEN
        RAISE NOTICE 'Unexpected error: %', SQLERRM;
END $$;