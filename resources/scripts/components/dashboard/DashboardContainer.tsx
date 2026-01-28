import React, { useEffect, useState } from 'react';
import { Server } from '@/api/server/getServer';
import getServers from '@/api/getServers';
import ServerRow from '@/components/dashboard/ServerRow';
import Spinner from '@/components/elements/Spinner';
import PageContentBlock from '@/components/elements/PageContentBlock';
import useFlash from '@/plugins/useFlash';
import { useStoreState } from 'easy-peasy';
import { usePersistedState } from '@/plugins/usePersistedState';
import Switch from '@/components/elements/Switch';
import tw from 'twin.macro';
import useSWR from 'swr';
import { PaginatedResult } from '@/api/http';
import Pagination from '@/components/elements/Pagination';
import { useLocation } from 'react-router-dom';
import Card from '@/reviactyl/ui/Card';
import Title from '@/reviactyl/ui/Title';
import { EmojiSadIcon, ChatAlt2Icon, XIcon } from '@heroicons/react/solid';
import { useTranslation } from 'react-i18next';

export default () => {
    const { t } = useTranslation('dashboard/index');
    const { search } = useLocation();
    const defaultPage = Number(new URLSearchParams(search).get('page') || '1');

    const [page, setPage] = useState(!isNaN(defaultPage) && defaultPage > 0 ? defaultPage : 1);
    const { clearFlashes, clearAndAddHttpError } = useFlash();
    
    // Ambil data user
    const user = useStoreState((state) => state.user.data!);
    const rootAdmin = user.rootAdmin;
    const username = user ? `${user.nameFirst}` : 'Member';
    
    // State untuk buka/tutup chat agar tidak menghalangi layar
    const [isChatOpen, setIsChatOpen] = useState(false);
    
    const [showOnlyAdmin, setShowOnlyAdmin] = usePersistedState(`${user.uuid}:show_all_servers`, false);

    const { data: servers, error } = useSWR<PaginatedResult<Server>>(
        ['/api/client/servers', showOnlyAdmin && rootAdmin, page],
        () => getServers({ page, type: showOnlyAdmin && rootAdmin ? 'admin' : undefined })
    );

    useEffect(() => {
        if (!servers) return;
        if (servers.pagination.currentPage > 1 && !servers.items.length) {
            setPage(1);
        }
    }, [servers?.pagination.currentPage]);

    useEffect(() => {
        if (error) clearAndAddHttpError({ key: 'dashboard', error });
        if (!error) clearFlashes('dashboard');
    }, [error]);

    return (
        <PageContentBlock className='pr-2' title={t('title')} showFlashKey={'dashboard'}>
            <div className='flex items-center justify-between py-4'>
                <div>
                    <Title className='text-4xl'>{t('title')}</Title>
                </div>
                {rootAdmin && (
                    <div className='flex items-center space-x-2'>
                        <p className='uppercase text-xs text-gray-400'>
                            {showOnlyAdmin ? t('other-servers') : t('your-servers')}
                        </p>
                        <Switch
                            name={'show_all_servers'}
                            defaultChecked={showOnlyAdmin}
                            onChange={() => setShowOnlyAdmin((s) => !s)}
                        />
                    </div>
                )}
            </div>

            {!servers ? (
                <Spinner centered size={'large'} />
            ) : (
                <div className='grid lg:grid-cols-2 gap-3'>
                    <Pagination data={servers} onPageSelect={setPage}>
                        {({ items }) =>
                            items.length > 0 ? (
                                items.map((server, index) => (
                                    <ServerRow key={server.uuid} server={server} css={index > 0 ? tw`mt-2` : undefined} />
                                ))
                            ) : (
                                <Card css={tw`col-span-1 lg:col-span-2`}>
                                    <p className='flex justify-center text-center text-sm text-gray-400'>
                                        <EmojiSadIcon className='w-5 h-5 mr-1' />{' '}
                                        {showOnlyAdmin ? t('no-other-servers') : t('no-servers')}
                                    </p>
                                </Card>
                            )
                        }
                    </Pagination>
                </div>
            )}

            {/* --- BAGIAN PREMIUM (DIPINDAHKAN KE BAWAH AGAR RAPI) --- */}
            <div className='mt-10 flex flex-col items-center space-y-4 border-t border-gray-800 pt-8'>
                <a 
                    href="https://wa.me/6283109105308" 
                    target="_blank" 
                    rel="noreferrer"
                    className='flex items-center space-x-3 bg-gray-800/40 hover:bg-cyan-900/20 px-4 py-2 rounded-xl border border-gray-700 hover:border-cyan-500 transition-all group'
                >
                    <img src="https://files.catbox.moe/ieo9o2.jpg" alt="Logo" className='w-6 h-6 rounded-full' />
                    <span className='text-sm font-bold text-gray-300 group-hover:text-cyan-400 transition-colors'>Order Panel Premium</span>
                </a>
                <p className='text-[10px] text-gray-600 uppercase tracking-widest'>Powered by IboyCloud</p>
            </div>

            {/* --- FLOATING CHAT WIDGET (MODERN & TIDAK MENGHALANGI) --- */}
            <div className='fixed bottom-6 right-6 z-50'>
                {/* Tombol Buka/Tutup */}
                <button 
                    onClick={() => setIsChatOpen(!isChatOpen)}
                    className={`p-4 rounded-full shadow-2xl transition-all transform hover:scale-110 ${isChatOpen ? 'bg-red-500 rotate-90' : 'bg-cyan-600 animate-bounce'}`}
                >
                    {isChatOpen ? <XIcon className='w-6 h-6 text-white' /> : <ChatAlt2Icon className='w-6 h-6 text-white' />}
                </button>

                {/* Kotak Chat Melayang */}
                {isChatOpen && (
                    <div className='absolute bottom-16 right-0 w-[330px] sm:w-[380px] h-[450px] bg-gray-900 border border-gray-700 rounded-2xl shadow-2xl overflow-hidden flex flex-col'>
                        <div className='bg-gray-800 px-4 py-3 border-b border-gray-700 flex justify-between items-center'>
                            <span className='text-sm font-bold text-cyan-400'>Global Chat Room</span>
                            <span className='text-[10px] text-gray-400 uppercase tracking-tighter'>User: {username}</span>
                        </div>
                        <div className='flex-1 bg-black'>
                            <iframe 
                                src={`https://www5.cbox.ws/box/?boxid=960956&boxtag=39mHaN&nme=${username}`} 
                                width="100%" height="100%" frameBorder="0" allowTransparence="true"
                            ></iframe>
                        </div>
                    </div>
                )}
            </div>
        </PageContentBlock>
    );
};
